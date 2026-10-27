# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

describe DivisionSummaryPipeline::EarlierDebate do
  let(:heading) { "Fair Pricing Amendment Bill 2026; Second Reading" }
  # Day 1: the amendment is moved inside a long debate, among speeches that move nothing.
  let(:first_day) do
    day_xml(<<~XML)
      <minor-heading id="h2">#{heading}</minor-heading>
      <speech id="s1" speakername="Robin Carrow" speakerid="uk.org.publicwhip/member/9101" time="12:33">
        <p>I rise to speak to the bill, and I move the amendment circulated in my name:</p>
        <p class="italic">That all words after "That" be omitted with a view to substituting the following words:</p>
        <p class="italic">"whilst not declining to give the bill a second reading, the House notes the cost to small business".</p>
        <p>Small businesses cannot absorb these costs.</p>
      </speech>
      <speech id="s2" speakername="Jess Harlow" speakerid="uk.org.publicwhip/member/9102" time="12:45">
        <p>I support the bill because it is fair.</p>
      </speech>
      <minor-heading id="h3">Another Bill 2026; Second Reading</minor-heading>
      <speech id="s3" speakername="Sam Okafor" time="13:00"><p>I move: That something unrelated happen.</p></speech>
    XML
  end
  # Day 2: debate ends and the division is deferred to the next sitting day.
  let(:second_day) do
    day_xml(<<~XML)
      <minor-heading id="h4">#{heading}</minor-heading>
      <speech id="s4" speakername="Jess Harlow" time="19:07">
        <p>The question is that the amendment moved by the member for Wattleford be agreed to. In accordance with standing order 133, the division is deferred until the next sitting day.</p>
      </speech>
    XML
  end
  # Day 3: the deferred question is put without debate.
  let(:third_day_division) do
    doc = day_xml(<<~XML)
      <minor-heading id="h5">#{heading}</minor-heading>
      <speech id="s5" speakername="Casey Whitlow" time="09:22">
        <p>In accordance with standing order 133, I shall now put the question on the amendment moved by the honourable member for Wattleford.</p>
      </speech>
      <division divdate="2026-05-14" divnumber="1" id="d1" time="09:27"><divisioncount ayes="40" noes="95"/></division>
    XML
    DataLoader::DebatesXml.new(doc, "representatives").divisions.first
  end
  let(:days) { { "2026-05-12" => first_day, "2026-05-13" => second_day } }
  let(:fetcher) { ->(_house, date) { days[date] } }

  def day_xml(body)
    Nokogiri::XML("<debates><major-heading id=\"h1\">BILLS</major-heading>#{body}</debates>")
  end

  it "finds the move and the deferral from earlier sitting days under the same heading, oldest first" do
    result = described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14", fetcher: fetcher)

    expect(result.dates).to eq(%w[2026-05-12 2026-05-13])
    expect(result.speeches.pluck(:speaker)).to eq(["Robin Carrow", "Jess Harlow"])
    expect(result.speeches.first[:moved_text]).to include("whilst not declining to give the bill a second reading")
    expect(result.speeches.first[:text]).to include("Small businesses cannot absorb these costs.")
  end

  it "leaves out speeches that neither move anything nor put a question, and other debates" do
    result = described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14", fetcher: fetcher)

    texts = result.speeches.pluck(:text).join
    expect(texts).not_to include("I support the bill because it is fair.")
    expect(texts).not_to include("something unrelated")
  end

  # Nothing quoted from an earlier day may be cut off part way through.
  it "keeps a long speech to an unbroken run of whole paragraphs round its move" do
    filler = (1..30).map { |n| "<p>#{"Paragraph #{n} is long. " * 60}</p>" }.join
    long_day = day_xml(<<~XML)
      <minor-heading id="h2">#{heading}</minor-heading>
      <speech id="s1" speakername="Robin Carrow" speakerid="uk.org.publicwhip/member/9101" time="12:33">#{filler}<p>I move:</p><p class="italic">That the bill be withdrawn.</p><p>That is my case.</p></speech>
    XML
    result = described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14",
                                     fetcher: ->(_house, date) { long_day if date == "2026-05-12" })
    kept = result.speeches.first

    expect(kept[:text].size).to be <= described_class::MAX_SPEECH_CHARS
    expect(kept[:paragraphs].pluck(:kind)).to include(:move, :motion)
    expect(kept[:paragraphs].pluck(:text)).to all(match(/[.:]\z/))
    expect(kept[:paragraphs].last[:text]).to eq("That is my case.")
  end

  # A quotation is not a move, so it must not stretch the kept run back to wherever it sits.
  it "keeps the run round the move when the speech also quotes someone far from it" do
    filler = (1..30).map { |n| "<p>#{"Paragraph #{n} is long. " * 60}</p>" }.join
    long_day = day_xml(<<~XML)
      <minor-heading id="h2">#{heading}</minor-heading>
      <speech id="s1" speakername="Robin Carrow" speakerid="uk.org.publicwhip/member/9101" time="12:33"><p>A report said:</p><p class="italic">The scheme is failing.</p>#{filler}<p>I move:</p><p class="italic">That the bill be withdrawn.</p><p>That is my case.</p></speech>
    XML
    result = described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14",
                                     fetcher: ->(_house, date) { long_day if date == "2026-05-12" })
    kept = result.speeches.first

    expect(kept[:text].size).to be <= described_class::MAX_SPEECH_CHARS
    expect(kept[:paragraphs].pluck(:kind)).to include(:move, :motion)
    expect(kept[:paragraphs].pluck(:kind)).not_to include(:quotation)
  end

  # As on 18 August 2026, when one such statement ran to 8,409 characters, all but two sentences
  # of it the amendments being put, which are other divisions' terms.
  it "keeps a long statement of the chair's putting another question, without the amendments printed in it" do
    circulated = "<p class=\"italic\">Omit all words after \"That\", substitute \"the House rejects the bill\".</p>" * 40
    doc = day_xml(<<~XML)
      <minor-heading id="h5">#{heading}</minor-heading>
      <speech id="s5" speakername="Casey Whitlow" time="09:22"><p>The question is that the amendments on sheet 9001 be agreed to.</p>#{circulated}</speech>
      <division divdate="2026-05-14" divnumber="1" id="d1" time="09:23"><divisioncount ayes="40" noes="95"/></division>
      <speech id="s6" speakername="Casey Whitlow" time="09:27"><p>The question is that the bill be now read a second time.</p></speech>
      <division divdate="2026-05-14" divnumber="2" id="d2" time="09:28"><divisioncount ayes="95" noes="40"/></division>
    XML
    second = DataLoader::DebatesXml.new(doc, "representatives").divisions.last

    kept = described_class.collect(division_xml: second, house: "representatives", date: "2026-05-14", fetcher: nil).speeches

    expect(kept.pluck(:text)).to eq(["The question is that the amendments on sheet 9001 be agreed to."])
  end

  it "stops at the most recent day with a move" do
    fetched = []
    counting = lambda do |house, date|
      fetched << date
      fetcher.call(house, date)
    end

    described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14", fetcher: counting)

    expect(fetched).to eq(%w[2026-05-13 2026-05-12])
  end

  it "skips a day that cannot be fetched rather than failing" do
    failing = lambda do |house, date|
      raise "connection reset" if date == "2026-05-13"

      fetcher.call(house, date)
    end

    result = described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14", fetcher: failing)

    expect(result.speeches.pluck(:speaker)).to eq(["Robin Carrow"])
  end

  it "does not look at earlier days when the division's date cannot be read" do
    fetched = []
    counting = lambda do |house, date|
      fetched << date
      fetcher.call(house, date)
    end

    described_class.collect(division_xml: third_day_division, house: "representatives", date: "not a date", fetcher: counting)

    expect(fetched).to be_empty
  end

  it "looks only at the division's own document when there is no fetcher" do
    result = described_class.collect(division_xml: third_day_division, house: "representatives", date: "2026-05-14", fetcher: nil)

    expect(result).to be_empty
  end

  # A guillotine's questions are put under "; Limitation of Debate", but the amendment was moved
  # in the second reading debate earlier the same day.
  context "when the question is put under another heading about the same bill" do
    let(:bills) { "<bills><bill id=\"r9001\" url=\"x\">Fair Pricing Amendment Bill 2026</bill></bills>" }
    let(:guillotined_division) do
      doc = day_xml(<<~XML)
        <minor-heading id="h2">#{heading}</minor-heading>
        #{bills}
        <speech id="s1" speakername="Robin Carrow" speakerid="uk.org.publicwhip/lord/9101" time="12:19">
          <p>I move:</p><p class="italic">Omit all words after "That", substitute "the Senate rejects the bill".</p>
        </speech>
        <minor-heading id="h3">Fair Pricing Amendment Bill 2026; Limitation of Debate</minor-heading>
        #{bills}
        <speech id="s2" speakername="Casey Whitlow" time="14:16"><p>The question is that the amendment moved by Senator Carrow be agreed to.</p></speech>
        <division divdate="2026-05-14" divnumber="1" id="d1" time="14:18">#{bills}<divisioncount ayes="12" noes="27"/></division>
      XML
      DataLoader::DebatesXml.new(doc, "senate").divisions.first
    end

    it "finds the move, marked as another stage of the bill" do
      result = described_class.collect(division_xml: guillotined_division, house: "senate", date: "2026-05-14", fetcher: nil)

      expect(result.speeches.pluck(:speaker)).to eq(["Robin Carrow"])
      expect(result.speeches.first[:other_heading]).to be(true)
    end

    it "keeps looking back for this debate's own move" do
      fetched = []
      counting = lambda do |_house, date|
        fetched << date
        nil
      end

      described_class.collect(division_xml: guillotined_division, house: "senate", date: "2026-05-14", fetcher: counting)

      expect(fetched).not_to be_empty
    end
  end

  # KNOWN_ISSUES.md KI-100: at House 16 September 2026 #4 the second reading had been moved 83 days
  # before, with 17 sitting days between, past both of the usual bounds.
  context "with a second reading moved months before its question" do
    let(:reading_heading) { "Example Rebate Bill 2026; Second Reading" }
    let(:question) { "The question now is that this bill be read a second time." }
    let(:reading_division) do
      doc = day_xml(<<~XML)
        <minor-heading id="h9">#{reading_heading}</minor-heading>
        <speech id="s9" speakername="Casey Whitlow" time="17:30"><p>#{question}</p></speech>
        <division divdate="2026-09-16" divnumber="4" id="d4" time="17:33"><divisioncount ayes="80" noes="50"/></division>
      XML
      DataLoader::DebatesXml.new(doc, "representatives").divisions.first
    end
    # Ten sitting days of debate before the question, the last of them past the usual bounds with
    # an amendment the question passes over, and the minister's move in June.
    let(:reading_days) do
      debate = "<minor-heading id=\"h8\">#{reading_heading}</minor-heading>" \
               "<speech id=\"s8\" speakername=\"Jess Harlow\" time=\"12:00\"><p>I support the bill.</p></speech>"
      days = (1..10).to_h { |i| [(Date.new(2026, 9, 15) - i).to_s, day_xml(debate)] }
      days["2026-09-05"] = day_xml(<<~XML)
        <minor-heading id="h7">#{reading_heading}</minor-heading>
        <speech id="s7" speakername="Robin Carrow" time="12:10"><p>I move:</p><p class="italic">That all words after "That" be omitted with a view to substituting "the House declines to give the bill a second reading".</p></speech>
      XML
      days["2026-06-25"] = day_xml(<<~XML)
        <minor-heading id="h6">#{reading_heading}</minor-heading>
        <speech id="s6" speakername="Morgan Treloar" time="09:11"><p>I move:</p><p class="italic">That this bill be now read a second time.</p><p>This bill makes the rebate fairer.</p></speech>
      XML
      days
    end
    let(:passed_over) { ->(text) { DivisionSummaryPipeline::MoverFinder.passes_over?(question: question, moved_text: text) } }

    def collect_reading(fetched = [], **)
      fetcher = lambda do |_house, date|
        fetched << date
        reading_days[date]
      end
      described_class.collect(division_xml: reading_division, house: "representatives", date: "2026-09-16",
                              fetcher: fetcher, passed_over: passed_over, **)
    end

    it "finds the second reading's own move past the usual bounds, and keeps nothing else from there" do
      result = collect_reading(second_reading: true)

      expect(result.speeches.pluck(:speaker)).to eq(["Morgan Treloar"])
      expect(result.speeches.first[:text]).to include("This bill makes the rebate fairer.")
      expect(result.dates).to eq(["2026-06-25"])
    end

    it "stops looking back once it finds that move, even on the sitting-day retry" do
      fetched = []
      collect_reading(fetched, second_reading: true, exhaustive: true)

      expect(fetched.last).to eq("2026-06-25")
      expect(fetched.size).to eq(83)
    end

    it "keeps to the usual bounds for any other question" do
      fetched = []
      result = collect_reading(fetched)

      expect(result.speeches).to be_empty
      expect(fetched.size).to be < 70
    end
  end
end

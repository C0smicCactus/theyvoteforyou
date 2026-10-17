# frozen_string_literal: true

require "spec_helper"

describe LocalHansardCache do
  let(:dir) { Rails.root.join("tmp/test_hansard_xml") }
  let(:cache) { described_class.new(dir: dir) }
  let(:scrapedxml) { %r{data\.openaustralia\.org\.au/scrapedxml/} }
  let(:sitting) { Date.new(2026, 8, 19) }
  let(:xml) do
    <<~XML
      <debates>
        <major-heading id="h1" url="x">BILLS</major-heading>
        <minor-heading id="h3" url="x">Example Bill 2026</minor-heading>
        <speech id="s1" speakername="Robin Carrow" time="10:00:00" url="x"><p>This change protects small business.</p></speech>
        <division divdate="2026-08-19" divnumber="1" id="d1" time="10:06:00" url="x"><divisioncount ayes="40" noes="30" pairs="0" tellerayes="0" tellernoes="0"/></division>
        <division divdate="2026-08-19" divnumber="2" id="d2" time="10:07:00" url="x"><divisioncount ayes="40" noes="30" pairs="0" tellerayes="0" tellernoes="0"/></division>
      </debates>
    XML
  end

  after { FileUtils.rm_rf(dir) }

  describe "#raw" do
    it "fetches a day once and reads it back from the folder" do
      stub_request(:get, scrapedxml).to_return(body: xml)

      expect(cache.raw("representatives", sitting)).to include("<division")
      expect(a_request(:get, scrapedxml)).to have_been_made.once
      expect(dir.join("representatives-2026-08-19.xml")).to exist
    end

    it "remembers a day with no XML, so it isn't asked for again" do
      stub_request(:get, scrapedxml).to_return(status: 404)

      expect(cache.raw("senate", sitting)).to be_nil
      expect(cache.raw("senate", sitting)).to be_nil
      expect(a_request(:get, scrapedxml)).to have_been_made.once
      expect(dir.join("senate-2026-08-19.missing")).to exist
    end
  end

  describe "#fetcher" do
    let(:fetch) { cache.fetcher }

    before { stub_request(:get, scrapedxml).to_return(body: xml) }

    it "parses each day once" do
      expect(fetch.call("representatives", sitting)).to equal fetch.call("representatives", sitting)
    end
  end
end

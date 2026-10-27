# Known issues in the division summary pipeline

`ARCHITECTURE.md` explains how this pipeline is meant to work. This file records where it does
not, so that the next person to pick it up starts from what is already known rather than
rediscovering it.

Entries are numbered `KI-n` so they can be cited from commits, issues and code comments. Numbers
are never reused. A fixed entry is kept as one line in the index below, naming the spec that
guards the fix, so a citation in the code still resolves. The full write-up of every fixed entry,
with the procedural sources and the reproduction, is in git history, as the lines removed by the
commit that condensed it: the first command below for KI-1 to KI-29, and the second for KI-35.

```
git log -p --grep='^Condense the known issues' -- app/services/division_summary_pipeline/KNOWN_ISSUES.md
git log -p --grep='^Read the chair' -- app/services/division_summary_pipeline/KNOWN_ISSUES.md
```

## Where these findings came from

KI-1 to KI-19 came from reading the pipeline against the two official procedural guides in
September 2026:

- **House of Representatives, _Guide to Procedures_, 6th edition 2017** (reprinted September
  2018, amended June 2019), Department of the House of Representatives. Cited below as
  "House Guide" with the guide's own printed page numbers.
- **_Guides to Senate procedure_**, Department of the Senate, the 23 numbered guides, each
  marked "Last reviewed: June 2025". Cited below as "Senate Guide No. _n_".

Both are Commonwealth publications licensed CC BY-NC-ND 3.0 AU, so neither is committed to this
repository. Download them from aph.gov.au if you need to check a citation. Neither guide is the
last word: `House of Representatives Practice` and `Odgers' Australian Senate Practice` are the
definitive texts, and both guides say so. For anything load-bearing, check there before
publishing.

KI-20 to KI-29 came from running the pipeline with seven Bedrock models over eight real divisions
from May and September 2026 (Senate 14 September #7, 16 September #15, 17 September #5 and #10;
House 14 May #1, 28 May #5, 14 September #1, 17 September #2), then replaying each day's
ParlParse XML through Stages 1 and 2 and running Stages 4 and 5 offline.

KI-30 came from restructuring the router in September 2026, when its routes were compared with
the previous router's over 173,880 generated questions.

KI-31 to KI-35 came from running the pipeline against local models through llama.cpp in September
2026 (Senate 20 August #32, a bill passed under a guillotine), then replaying the model's intended
answer, and the router's default, through Stages 4 and 5 with the model call stubbed out.

KI-36 and KI-37 came from checking that same division's draft against Hansard in September 2026,
then replaying the Senate's ParlParse XML for 18 to 20 August 2026 (69 divisions, 47 of them put
under one of five guillotines) through Stage 1.

KI-38 and KI-39 came from checking the draft for Senate 20 August 2026 #23 against Hansard in
September 2026, after three local models all quoted the same passage as the mover's explanation,
then comparing Stage 1 before and after the fix over the 3,856 speeches in the ParlParse XML for
Senate 18 to 20 August 2026 and the eight test divisions' sitting days.

KI-40 onwards came from running four local models over ten divisions from 12 to 20 August 2026 on
30 September 2026, reviewing every draft against Hansard, and checking the proposed changes against
the chambers' standing orders and guides. That check found that some of the pipeline's House
procedure had been written from the House Guide (2017, amended June 2019), which predates every
change to the House standing orders from 4 July 2019 to 23 July 2025: the standing orders "as at 23
July 2025" outrank it. The Senate standing orders consulted then were the June 2009 edition. The
July 2025 edition replaced them on 1 October 2026, and every Senate standing order the pipeline
cites kept its number and substance.

This register was compiled with AI assistance (Claude Code: claude-opus-5[1m] for KI-1 to KI-19,
claude-opus-5-5 for KI-20 to KI-39 and later, and for condensing the fixed entries). The procedural
citations should be checked against the guides named above.

## How findings were verified

- **Confirmed** means the behaviour was reproduced by running the code, not inferred from
  reading it.
- **Read** means it follows from the source but was not executed.
- **Inferred** means it is a conclusion drawn from the evidence rather than observed, and the
  entry says what it rests on.
- **Verify** means it needs checking against a primary source before anyone acts on it.

## Index

**Kind** says what it takes to tell whether a draft is right. **Rules**: a standing order or
procedural guide is needed. **Pipeline**: the code, the prompt, the drafts and Hansard are enough.
Every entry has one kind, so every issue has one place, and the open entries are grouped by it.

Colours: **Severity** 🔴 High, 🟠 Medium-High or Medium, 🔵 Low. **Status** 🟢 Fixed,
🟠 Partly fixed, 🟡 Verify (needs checking against a source), 🔴 Open.

| ID | Kind | Severity | Status | Summary | Guarded by, and what is still worth knowing |
|---|---|---|---|---|---|
| KI-1 | Pipeline | 🔴 High | 🟢 Fixed | Template 6's closing sentence ignored the vote result, and named a destination chamber the data cannot support. The second reading, which Template 6 then also covered, is now Template 29 | `template_compiler_spec.rb` "Templates 29 and 6, reporting the result of the reading and not just the reading". The destination is stated only when `bill_originating_house` is supplied; nothing supplies it yet. |
| KI-2 | Rules | 🔴 High | 🟢 Fixed | Template 7 read every message question as "agree to the other chamber's amendments" | `template_compiler_spec.rb` "Template 7, the forms a message question takes". Still open: insisting on an amendment that itself omitted a clause (Odgers', via Senate Guide No. 18) is not told apart from an ordinary insist. The same goes for a tie: on "does not insist", `SummaryWording#not_insist_effect_clause` says the amendments are not insisted on, but where the amendment was one to omit a clause, an equal vote means "the amendment to omit the clause is insisted on" (Senate Guide No. 18, p. 56). |
| KI-3 | Pipeline | 🔴 High | 🟢 Fixed | Template 22 contradicted itself for "the business of the day be called on" | `template_compiler_spec.rb` "Template 22, the three questions that arrive as a closure". A template per closure form would be tidier; that is a catalogue decision. |
| KI-4 | Rules | 🔴 High | 🟠 Partly fixed | Real question forms fall through to Template 15 | See the open entry below. |
| KI-5 | Rules | 🔴 High | 🟢 Fixed | Absolute-majority questions were reported on a simple-majority test | `template_compiler_spec.rb` "constitutional and parliamentary procedures" and "Template 17, the purpose a suspension states for itself". The pipeline flags the doubt rather than resolving it: the question alone does not say how a suspension was moved. Corrected in September 2026 against House S.O. 47 as at 23 July 2025: a House suspension without notice is also carried by a majority of those present if the Leader of the House and the Manager of Opposition Business agree, and "by leave" is said only of the House, where the House Guide (p. 2) supports it; neither Senate source mentions it ("gives each chamber's own ways to carry a suspension on a simple majority"). The House Guide (2019) predates S.O. 47's amendments of 23 March 2020 and 27 July 2022, and the current S.O. 47 (p. 33) does not mention leave: **Verify** that a House suspension moved by leave still needs only a majority. S.O. 47(c)(ii)'s alternative is "a majority of Members present", where the notice says "a majority of those voting". |
| KI-6 | Rules | 🟠 Medium | 🟢 Fixed | Deferred and successive divisions defeated the context window | `context_builder_spec.rb` "context warnings". The S.O. 133 time windows are this code's own estimate, not a figure from either guide; they only raise a warning. Corrected in September 2026 against House S.O. 133 as at 23 July 2025: the Tuesday window after the matter of public importance was S.O. 133's own rule when the House Guide was written (p. 58) and is not in the current S.O. 133, so it is gone ("does not warn about a Tuesday afternoon"). S.O. 133(b) now defers evening divisions from Monday to Wednesday "until the first opportunity the next sitting day", which fixes no time; a window for it caught only programmed questions, so it rests on the chair's words, as a deferral on another day already did. The Senate's half also rests on the chair's words, and is partly open (KI-81). |
| KI-7 | Rules | 🟠 Medium | 🟢 Fixed | Template 24 stated the wrong suspension period and the House wording in the Senate | `template_compiler_spec.rb` "Template 24, suspension periods and the two chambers' wording", "uses the Senate's form of words and its own suspension periods". The House periods follow House S.O. 94(d) as at 23 July 2025, the Senate's S.O. 204(1) and (2) (July 2025, p. 102), all three given since the data does not say which occasion it was. The explainer says the Chair "has named them", no longer "for disorderly conduct": Senate S.O. 203(1) (p. 102) lists five offences, and Senate Guide No. 2 (p. 6) calls the report to the Senate a naming. |
| KI-8 | Rules | 🟠 Medium | 🟢 Fixed | House quorum hardcoded against a 2019 date | `template_compiler_spec.rb` "constitutional and parliamentary procedures". The quorum comes from the House's seats on the day, 151 from the 2019 election to the 2025 election, not from the member records, which count fewer during a vacancy (KI-74). |
| KI-9 | Rules | 🟠 Medium | 🟢 Fixed | Template 2 overstated what carrying a reasoned amendment does | Template 2's explainer (no spec). |
| KI-10 | Rules | 🟠 Medium | 🟢 Fixed | Template 17 asserted a purpose the question usually does not support | `template_compiler_spec.rb` "Template 17, the purpose a suspension states for itself". |
| KI-11 | Rules | 🟠 Medium | 🟢 Fixed | `declines_second_reading` was left to the model when the guides give a closed list of forms | `provenance_validator_spec.rb` "declines_second_reading against the motion text". Extended in September 2026 (`provenance_validator_spec.rb` "with the forms whose words settle it"): the words also settle it as declining when the amendment rejects the bill (the Senate's usual form) or would finally dispose of it (House S.O. 146, "now" to "not"; Senate S.O. 114(2), "this day 6 months"), and as not declining when a Senate amendment only adds words expressing an opinion. An addition that refers or delays the bill is left to the model (Senate Guide No. 16), and a House amendment that adds words, which S.O. 145(a)(iii) does not allow, is a warning. The House's "disapproves of ... charges" form is no longer listed as not declining: the guide does not classify it. Since KI-87 an addition is left to the model only when it refers, delays or defeats the bill in an operative form, not when it only mentions a committee or a delay, and the editor is warned whenever the words leave the flag to the model. |
| KI-12 | Rules | 🔵 Low | 🟢 Fixed | Template copy the guides sharpen (1, 3, 4, 5, 8, 9, 10, 14, 16, 18, 20, 22, 25, 26, 27, 28) | Template text (no spec). Template 23 was checked and is right: the Senate has no gag. Checked against the House Guide (2017), which the House standing orders have since overtaken: Template 18's House half was out of date until KI-47. |
| KI-13 | Rules | 🔵 Low | 🟠 Partly fixed | Template 2 described one of the four things a stage amendment can do | See the open entry below. |
| KI-14 | Pipeline | 🔵 Low | 🟢 Fixed | `ARCHITECTURE.md` drift: template count, adjournment, Senate quorum | Documentation. |
| KI-15 | Pipeline | 🔴 High | 🟢 Fixed | `declines_second_reading` and `sufficient_context` were coerced to true whatever the model returned | `extraction_payload_spec.rb` "boolean fields". |
| KI-16 | Rules | 🔴 High | 🟢 Fixed | A suspension of standing orders was routed as whatever motion it quoted | `procedural_router_spec.rb` "suspension of standing orders is matched before the motion it would enable". The suspension rule must stay first in the router. |
| KI-17 | Pipeline | 🟠 Medium | 🟢 Fixed | The compiler's grammar tidying edited quoted Hansard | `template_compiler_spec.rb` "verbatim quoted text". |
| KI-18 | Rules | 🟠 Medium | 🔴 Open | A tied House division cannot be resolved from the recorded figures | See the open entry below. |
| KI-19 | Rules | 🔵 Low | 🟡 Verify | Template 21 cites the Parliament Act 1974, which neither guide mentions | See the open entry below. |
| KI-20 | Pipeline | 🔴 High | 🟢 Fixed | Stage 1 misread current ParlParse XML: glued paragraphs, and no motion text | `speech_text_spec.rb`, `division_xml_spec.rb`, `context_builder_spec.rb` "Hansard in the shape current ParlParse produces". Current XML has no `pwmotiontext`; the terms moved are italic paragraphs after "I move". |
| KI-21 | Pipeline | 🔴 High | 🟢 Fixed | A deferred division, or a long debate, left the motion out of the packet | `earlier_debate_spec.rb`, `context_builder_spec.rb`, `division_xml_spec.rb`. |
| KI-22 | Pipeline | 🔴 High | 🟢 Fixed | Almost every division was called a conscience vote | `template_compiler_spec.rb` "facts the drafts from real divisions got wrong". `Whip#free_vote?`'s list stops at 1 December 2022, so a later conscience vote is not called one until someone adds it. |
| KI-23 | Rules | 🟠 Medium | 🟢 Fixed | Real question forms routed to the wrong template or too wide a fence | `procedural_router_spec.rb` "routing on the motion as moved" and "questions taken from recent Hansard"; `semantic_extractor_spec.rb`. |
| KI-24 | Pipeline | 🟠 Medium | 🟢 Fixed | The mover was whoever the model credited, or "a member" | `mover_finder_spec.rb`, `template_compiler_spec.rb`, `division_summarizer_spec.rb`. The September 2026 local model run found "a motion introduced by a member" still in Template 12's vote sentence, and House members titled "Representative Kate Chaney", which is not Australian usage. Every template now prints the mover through `{{mover_clause}}`, which is empty with no mover, and House members are named in the site's own form, "Kate Chaney MP" (`Member#full_name_no_electorate`), the member in the chair too (`template_compiler_spec.rb` "naming members of the House"). |
| KI-25 | Pipeline | 🟠 Medium | 🟢 Fixed | Stage 4 rejected genuine quotes over formatting, and let weak evidence through | `provenance_validator_spec.rb`, `text_normaliser_spec.rb`. |
| KI-26 | Pipeline | 🔵 Low | 🟢 Fixed | Wording built from verbatim text read badly in Templates 2, 16, 17 and 19 | `template_compiler_spec.rb`. Reopened for Template 17 by the September 2026 local model run and fixed again: the suspension's purpose was spliced into the sentence unquoted, so "prevent me from moving a motion" read as They Vote For You speaking. It is now quoted in the standard form's own words, "as would prevent ..." (`template_compiler_spec.rb` "quotes a purpose the mover states in the first person"). Reopened for Template 19 the same way: "specifically that" spliced in whatever the model pointed at, printing "specifically that That". The description is now quoted, found by rule for a one-paragraph motion, optional, and refused when it is too short or is the chair's question (`template_compiler_spec.rb` "Template 19, what the rearrangement does"; `provenance_validator_spec.rb` "with a rearrangement of business"). |
| KI-27 | Pipeline | 🟠 Medium | 🟢 Fixed | The context retry leaked one model's note and re-routed the division | `context_builder_spec.rb`, `semantic_extractor_spec.rb`, `division_summarizer_spec.rb`. |
| KI-28 | Pipeline | 🟠 Medium | 🟢 Fixed | Validator warnings and the review flag were thrown away | `reviewer_report_spec.rb` "lists the fallbacks, the warnings and how the mover was found"; `division_summarizer_spec.rb`. Every draft, a failed one included, ends with a fixed Reviewer Only report carrying Stage 1's context warnings, the validation errors and warnings, and the fallbacks used. |
| KI-29 | Pipeline | 🟠 Medium | 🟠 Partly fixed | Findings from the same audit | See the open entry below: one finding is still open, and each fixed one names its spec. |
| KI-30 | Pipeline | 🔵 Low | 🟢 Fixed | The router's bill-title stripping could take a capitalised "Amendment" that is not in a title | `procedural_router_spec.rb` "does not take a capitalised amendment just before the bill's name as part of the title". A title runs through "the" or "to" only inside parentheses. "That the Example Amendment Bill 2026 be disagreed to" still reaches the fallback, rightly: only its title says "amendment" (KI-29), and it is amendments, not a bill, that a chamber disagrees to (House S.O. 161(c), p. 70; Senate S.O. 126(2), p. 75). |
| KI-31 | Rules | 🟠 Medium | 🟢 Fixed | "That the remaining stages of the bill be agreed to, and the bill be now passed" fell to the general motion fallback | `procedural_router_spec.rb` "routes the remaining stages being agreed to and the bill passed to Template 6". A model that took the fallback's default compiled a valid draft that never said the bill passed. |
| KI-32 | Pipeline | 🟠 Medium | 🟢 Fixed | A question that is the whole motion sent the pipeline to read the whole sitting day | `extraction_prompt_spec.rb` "tells the model there are no terms to find when the question is the whole motion"; `division_summarizer_spec.rb` "when the question is the whole motion and the model reports its terms missing". The prompt told the model to report the terms missing whatever the question, and the retry read about 70,000 tokens that could not contain them. `ContextPacket::QUESTION_IS_THE_MOTION` lists the templates this applies to. Extended in September 2026, after two models reported the mover's speech missing for such a question and one retry read 78,535 tokens: a mover's speech reported missing is no reason to widen when nobody moved anything (the question is the whole motion, or the amendments were circulated and put, and no mover was found; a limitation of debate alone stopped counting with KI-70), nor are terms Stage 1 found by rule, and the prompt says so (`division_summarizer_spec.rb` "does not widen for a mover's speech reported missing either"; `extraction_prompt_spec.rb`). |
| KI-33 | Pipeline | 🟠 Medium | 🟢 Fixed | A failed sitting day retry threw away a first reply that would have compiled | `division_summarizer_spec.rb` "when the retry over the whole sitting day fails"; `reviewer_report_spec.rb`. The draft is now built from the first reply and the Reviewer Only report says why. |
| KI-34 | Rules | 🔵 Low | 🟢 Fixed | Template 6 said "a motion introduced by a member" and "third reading" for the remaining stages question the chair puts | `template_compiler_spec.rb` "names every remaining stage, and no mover, when the question takes the remaining stages together". Its Bill Timeline still explains the third reading, which the remaining stages end with. |
| KI-35 | Pipeline | 🟠 Medium | 🟢 Fixed | A lead-in sentence before the chair's question could decide the route, and so could the amendments Hansard prints after it, or an earlier question in the same statement | `chair_statement_spec.rb` "#question"; `division_xml_spec.rb` "#operative_question"; `context_builder_spec.rb` "when the chair puts amendments nobody moved in the chamber"; `procedural_router_spec.rb` "routes the chair's question sentence, whatever the rest of the statement said". `ChairStatement` reads the statement once: the division's question is the last question sentence of the chair's own words ("The question is", "now is", "first", "immediate", "next"), after any question closed by "Question agreed to." and the like. Comparing routes over the 121 loaded divisions of May to September 2026 moved 42, every one a correction: seven questions had been settled on words in the chair's lead-in (three as closures because it said "I'll now put the question", one as a guillotine because it said "time allotted") and a dozen statements put and closed one question before putting the division's. MoverFinder reads the paragraphs that put the question, where the chair often names the mover. |
| KI-36 | Rules | 🟠 Medium | 🟢 Fixed | A question put once a guillotine's time had expired never said so, so a draft read as an ordinary vote with nobody moving or debating it | `division_xml_spec.rb` "#limitation_of_debate_statement"; `context_builder_spec.rb` "when a guillotine's time has expired"; `template_compiler_spec.rb` "says the question was put under a limitation of debate". Found by rule from the chair's statement, which can be dozens of divisions back under another bill's heading. A senator asking by leave or on indulgence to have their position recorded no longer stops the search (`division_xml_spec.rb` "walks past a senator asking by leave or on indulgence to have their position recorded"): on 18 August 2026 that had left two of the four divisions under the second reading's guillotine unmentioned, the second reading itself among them, and both are now found. Any other speech by leave, such as tabling a document, still stops it. |
| KI-37 | Pipeline | 🟠 Medium | 🟢 Fixed | Earlier debate was matched by heading alone, so a question put under "; Limitation of Debate" never found the amendment moved under the same bill's "; Second Reading" | `debates_xml_headings_spec.rb`, `division_xml_spec.rb` "finds the same bill's debate under another heading"; `earlier_debate_spec.rb`, `mover_finder_spec.rb`, `context_builder_spec.rb`. Sections are also matched by the bills listed under their headings. Such a move is only kept when the chair names its mover and nothing under the division's own heading was found: an unnamed one, such as a second reading question straight after the amendment, belongs to a different question. |
| KI-38 | Pipeline | 🔴 High | 🟢 Fixed | Words a member quoted or read out were quoted as the member's own explanation | `speech_text_spec.rb` "labels an italic paragraph that follows no move as a quotation"; `transcript_spec.rb` "keeps a passage the member quoted whole"; `provenance_validator_spec.rb` "when the mover quotes someone else"; `earlier_debate_spec.rb` "keeps the run round the move when the speech also quotes someone far from it". At Senate 20 August 2026 #23 all three models picked a sentence of the Prime Minister's 2003 words that the mover had read out, and the draft printed it under the mover's name. Hansard sets quoted material in italic, so an italic paragraph that is neither a motion nor part of an incorporated speech is now a `:quotation` unit, which the validator never accepts as an explanation. Still open: a short quote inside a member's own sentence ("they say: 'No worries!'") is not set apart, and neither is a quote inside an incorporated speech, so those rest on the model and the reviewer. |
| KI-39 | Pipeline | 🟠 Medium | 🟢 Fixed | An incorporated second reading speech opening with the House's "I move that this Bill be now read a second time." was read as a move, and the whole speech as its terms | `speech_text_spec.rb` "a speech incorporated by leave" and "reads a move made while presenting a report or tabling a document". Three Senate speeches on 19 and 20 August 2026 gave 7,339 to 14,500 characters of speech as the motion moved; none of the sitting days checked has a division on those bills, so none of the drafts checked here used it. Fixing it exposed that "I table ... and move:" was never read as a move either, so one of the three ministers had been found only through the copied line; tabling and presenting forms are now read. |
| KI-40 | Pipeline | 🟠 Medium | 🟢 Fixed | The prompt a draft was made from was not kept, only the model's reply, and cannot be rebuilt once Hansard or the code has changed | `ai_division_summary_spec.rb` "keeps a prompt and a draft longer than a TEXT column holds"; `division_summarizer_spec.rb` "keeps the prompt the model was sent", "keeps the prompt of the reply the draft was built from". The prompts are on `system_prompt` and `user_prompt`, MEDIUMTEXT like `description` now, because a sitting day prompt ran to 104,305 bytes and a guillotine draft to 50,610, against TEXT's 65,535. Local runs also write each request beside its reply. |
| KI-41 | Pipeline | 🔴 High | 🟢 Fixed | A chair's statement over 1,200 characters was not taken for the chair's, so a draft said the question was never recorded, and quoted all 45,679 characters when it was | `division_xml_spec.rb` "is the chair's statement however many amendments Hansard prints in it"; `transcript_spec.rb` "#question_units"; `provenance_validator_spec.rb` "quotes only the chair's words putting the division's question"; `earlier_debate_spec.rb` "keeps a long statement of the chair's putting another question". The size limit is applied to the plain paragraphs only: the italic ones are the amendments being put. Question Put quotes the chair's words putting the division's question, and the earlier debate keeps only the chair's words from earlier statements. |
| KI-42 | Pipeline | 🔴 High | 🟢 Fixed | The validator accepted the chair putting a question as the terms of the motion moved | `provenance_validator_spec.rb` "never takes the chair putting or deciding a question as the terms moved". A model motion reference whose text is a chair's question sentence or "Question agreed to." and the like is refused with a warning, whoever the transcript says spoke it: at Senate 18 August 2026 #16 a draft printed "The question now is that amendments ... be agreed to." as the amendment moved. |
| KI-43 | Rules | 🔴 High | 🟢 Fixed | Amendments nobody moved were credited to whoever last moved anything: a party's circulated amendments to the minister who had moved the second reading, with the minister's case for the bill offered as the case against it | `mover_finder_spec.rb` "does not credit a move whose terms cannot be what the question puts", "does not guess an unnamed mover for amendments the chair says were circulated"; `chair_statement_spec.rb` "#circulated_by"; `context_builder_spec.rb` "when the chair puts amendments nobody moved in the chamber"; `template_compiler_spec.rb` "amendments the chair put without anyone moving them". An unnamed move counts only when its terms could be what the question puts, and not at all when the chair says the amendments were circulated. Who circulated them is found by rule, from the chair's words or Hansard's heading over them, and the draft says "circulated by the Australian Greens ... were put", never "moved". Every template now prints the mover through `{{mover_clause}}`, so a draft with no mover says nothing rather than "introduced by a member". With no mover, an explanation can only be the circulating member's words. |
| KI-44 | Pipeline | 🟠 Medium | 🟢 Fixed | The terms of amendments the chair put under a limitation of debate were left for the model to find, though the chair's statement prints them | `transcript_spec.rb` "takes the amendments printed after the division's question as its terms"; `context_builder_spec.rb` "takes the amendments the chair put as the terms", "keeps the plain headings Hansard sets among the amendments"; `extraction_prompt_spec.rb` "tells the model when the chair put amendments nobody moved"; `division_summarizer_spec.rb` "does not widen for amendments the chair put". The paragraphs after the question sentence, up to the next record or question, are the terms, found by rule, when the question refers to amendments; in the House, unmoved opposition amendments are sometimes printed only for the record (House Guide p. 75), so nothing else is taken. 26 of the 121 loaded divisions now have their terms found by rule, and none of them sends the model to the sitting day for them. The House Guide's note (p. 75) describes the guillotine as it was before S.O.s 83 and 84 were omitted on 27 July 2022; S.O. 85(c) now treats circulated amendments to an urgent bill as moved, so the caution is harmless and was kept. |
| KI-45 | Pipeline | 🟠 Medium | 🟢 Fixed | Template 28 did not say which parts of the bill were to stand as printed, or whose amendments to omit them the vote decided | `template_compiler_spec.rb` "names the parts the question named, and who circulated the amendments to omit them". The parts are the chair's words between "that" and "stand as printed" in the division's question, quoted, and who circulated the amendments comes from `Circulation`. |
| KI-46 | Pipeline | 🔴 High | 🟢 Fixed | Every closure not on a bill said "to end the debate on bill", and one on a bill left out "the" | `template_compiler_spec.rb` "Template 22, a closure on a bill and on anything else"; the evaluation corpus fixture 2. With no bill the sentence ends the debate and names none. `bill_reference` was checked everywhere else it is used: every other use follows "the". |
| KI-47 | Rules | 🟠 Medium-High | 🟢 Fixed | Template 18 described the House guillotine from the House Guide (2017): a declaration of urgency followed by a motion allotting time. S.O.s 83 and 84 were omitted on 27 July 2022, and there is no allotment of time any more | Template text (no spec). Rewritten from House S.O. 82 and 85 as at 23 July 2025: the declaration of urgency, one evening's second reading debate to 10 pm, the questions then put without debate at the next sitting, circulated amendments treated as moved and put in groups (government, opposition, each crossbench member), and no closure. The catalogue line and the router's reason say the same. The Senate half matches Senate Guide No. 17 and was kept. Checking the other House standing orders the pipeline cites found S.O. 122 changed since the guide: since July 2019 it puts "That the amendment be agreed to", noted under KI-68. Template 23 now also says S.O. 80 bars the gag while a member is moving the terms of a motion; that bar is older than S.O. 80's amendment of 23 July 2025, since the House Guide already gives it (p. 48). S.O. 47, 94 and 133 changed too (KI-5, KI-7, KI-6). S.O. 31 and 131 were reread and say what the pipeline says of them; S.O. 11, 46, 58, 81, 87, 135, 150, 153, 173, 188 and 202 have not been amended since the guide, so the earlier check against it stands. S.O. 29 was amended in 2022, but only its sitting times. |
| KI-48 | Pipeline | 🔵 Low | 🟢 Fixed | Wording that read as machine output or overstated its source: "1 senator(s)", a Motion Introduction of just "I move:", "decline the bill a second reading", "which means ... This means", "It has happened once, in 2016" stated as current fact from a 2017 guide, "Ndis" for "NDIS" in titles, and "they agreed" for the chamber | `template_compiler_spec.rb` "wording that read as machine output", "Template 2's explainer in each chamber"; `draft_title_spec.rb` "prints a bill's title in the heading as the bills table records it"; the evaluation corpus. A section with nothing left in it is now left out, heading and all, which is how the bare "I move:" goes. `DivisionFacts#bill_titles` carries every bill's own title for `DraftTitle`; `DivisionXml#name` keeps its PHP-compatible casing. |
| KI-49 | Rules | 🟠 Medium | 🟢 Fixed | Subject rules outranked the bill-stage rules, so a reasoned amendment read out as the question was settled as whatever it named: a select committee, or a censure | `procedural_router_spec.rb` "routes the form proposing a select committee to Template 2", "routes a Budget amendment worded as a censure to Template 2", "leaves the same form amending an ordinary motion to the other rules". `reasoned_amendment_form` settles Template 2 when the question reads out an amendment's own form in a second reading debate, before any subject rule. None of the 121 loaded divisions changed route; since KI-35, the Senate's questions no longer carry the amendments' words, so this is for a House chair reading an amendment out. KI-13's note that the Budget case already worked was wrong and has been corrected. |
| KI-50 | Rules | 🟠 Medium-High | 🟠 Partly fixed | A motion whose first paragraph Hansard sets as "That—" alone was routed on that one word; it is now read whole, but the limitation of debate it sets is routed only as advice | See the open entry below. |
| KI-51 | Rules | 🔵 Low | 🟢 Fixed | The plain second reading question ("That the bill be now read a second time") was fenced between Templates 2 and 29 though it names no amendment | `procedural_router_spec.rb` "settles the plain second reading question on Template 29", "fences a second reading question that is not in the plain form". Settled as Template 29 in that form with no amendment wording and not "as amended"; anything else still fenced. Three of the 121 loaded divisions moved from the fence to 29, each a plain second reading. |
| KI-52 | Rules | 🟠 Medium | 🟠 Partly fixed | A House question put under a resolution agreed earlier, "immediately" or once the time it allotted had expired, read as an ordinary debated vote; more forms are still missed | See the open entry below. |
| KI-53 | Pipeline | 🟠 Medium | 🟢 Fixed | A divided question was summarised, and its motion printed, as though the whole motion had been put | `chair_statement_spec.rb` ".divided_parts"; `template_compiler_spec.rb` "a divided question". When the chair's question puts a motion "minus" or "except" some of its parts, the draft says the vote was on the motion without them, in the chair's words, and the Reviewer Only report says the question was divided. Senate forms only: the House, where a member may move that a question be divided (House S.O. 119), had none in its Hansard from May to September 2026, so none is assumed. A divided question put on the separated part itself is not recognised. |
| KI-54 | Pipeline | 🟠 Medium | 🟢 Fixed | A closure's draft said only that "the debate" ended, and never linked the division that then put the underlying question | `context_builder_spec.rb` "with a closure"; `template_compiler_spec.rb` "says what the debate it ended was on". Stage 1 routes the move the closure cut short (the last one before the closure's own, in the same debate, by someone else) and keeps the template when that settles one, which the sentence names: "to end the debate on a motion to suspend standing orders". The follow-up division is the next that day in the same debate, unless it is a closure itself, looked up in the database. ARCHITECTURE.md section 15's `followup_link` item is built. |
| KI-55 | Pipeline | 🔵 Low | 🟢 Fixed | A matter of urgency did not say whose proposal it was; words incorporated in Hansard were quoted as "Senator X said:"; and a question the chair put with nobody moving it printed empty Motion Introduction and Motion Text sections | `context_builder_spec.rb` "finds who proposed a matter of urgency someone else moved"; `template_compiler_spec.rb` "what a draft says about who moved what"; `transcript_spec.rb` "marks the words of a speech incorporated by leave"; `provenance_validator_spec.rb` "records when the chair put a question that is the whole motion with nobody moving it". The proposer comes from the chair's "Senator X has submitted a proposal" and a surname is linked only when one senator on the day has it; incorporated words are introduced as "Senator X's speech, incorporated in Hansard, reads:"; and when nobody moved anything the sections are left out, and the Question Put section quotes the question. |
| KI-56 | Pipeline | 🟠 Medium | 🟢 Fixed | In Templates 1, 5, 6 and 29 the mover's words sat under "About the Bill" straight after the Bills Digest, so once a digest is wired in a reader could take the mover's case for the Parliamentary Library's | `template_compiler_spec.rb` "gives the mover's words their own heading, apart from the Bills Digest". They are under "### About the Motion", as in the other templates (heading chosen by Blake, 30 September 2026). With nobody moving anything the section is left out. |
| KI-57 | Pipeline | 🟠 Medium | 🟢 Fixed | Hansard's records of the chamber inside a member's speech ("Leave not granted.", "(Time expired)", "Opposition senators interjecting—", "Question agreed to.") were the member's own sentences, so the validator would have accepted one as their explanation | `speech_text_spec.rb` "labels Hansard's records of the chamber as records"; `transcript_spec.rb` "marks Hansard's record at the end of a paragraph as a record"; `provenance_validator_spec.rb` "drops Hansard's record of the chamber inside the mover's speech". A paragraph or sentence that is wholly one of a closed list of forms, from House and Senate Hansard of May to September 2026, is a `:record`: shown to the model as "record" and never accepted as an explanation. Not `:quotation`, because in the chair's statement "Question agreed to." closes a question rather than joining the amendments printed after it. The nightly loader's `#motion` is untouched. No draft in the run printed one; the Senate XML for 12 to 20 August alone had "Leave granted." or "Leave not granted." about 45 times. |
| KI-58 | Pipeline | 🟠 Medium | 🟠 Partly fixed | The prompt let a model pick remarks aimed at other members as "the mover's case", and left it unclear what Template 17's explanation should hold; some models still pick them | See the open entry below. |
| KI-59 | Pipeline | 🔵 Low | 🟢 Fixed | When the question settled a template and the model could not find what that template is about, the pipeline read the whole sitting day again instead of doubting the route | `division_summarizer_spec.rb` "does not widen when the model cannot find what a settled template is about, and says so". `TemplateCatalogue::DEFINING_EVIDENCE` (a committee for 12 and 13, a regulation for 9, a target for 10, 23 and 24): with a settled route, that report is not a reason to widen, and the validator warns the reviewer to check the route. |
| KI-60 | Pipeline | 🟠 Medium | 🟢 Fixed | Earlier speeches that moved something else were sent whole even when the chair had named a different mover, though only the mover's sentences can be quoted | `context_builder_spec.rb` "cuts another member's earlier speech to what it moved, once the chair has named the mover". Once the mover is known, another member's earlier speech keeps only its "I move" words and terms. House 18 August 2026 #3's user prompt fell from 33,582 characters to 18,033 with its route and mover unchanged, and no loaded division changed route. |
| KI-61 | Pipeline | 🔵 Low | 🔴 Open (deferred) | Sentences left out between quoted ones are not marked | See the open entry below. |
| KI-62 | Pipeline | 🔴 High | 🟢 Fixed | The mover of a closure was taken as the mover of the question it brought on, so a second reading draft quoted "That the question be now put" as its motion | `mover_finder_spec.rb` "with a closure moved just before the question", `context_builder_spec.rb` "does not take the closure's mover for the mover of the question it brought on". `MoverFinder` passes a closure over when the question names a reading or a suspension, the business a closure brings on; a question that restates the closure, speaks of closure, names nothing ("that the motion be agreed to") or doesn't read as a question still takes it. Of the 910 divisions of 2026, 12 change: 7 suspensions (one in the House) now find their own mover and terms, 5 of them drafted before as "Closure of Debate"; 5 find no mover where they had the closure's. Two of those are second readings moved on an earlier day (Senate 1 July 2026 #1, 17 September 2026 #1), which `ContextBuilder#earlier_debate` didn't look for, since the closure beside the division counted as a move. Three are suspensions whose mover moved the closure straight after them, in the same speech (Senate 10 March 2026 #2, 23 March 2026 #2, 1 July 2026 #8). `SpeechText#moved_text` keeps only the last thing a speech moved, so the suspension's own move is not seen; before this fix those three named the right senator, but with the closure as the motion. |
| KI-63 | Pipeline | 🔴 High | 🟢 Fixed | A motion moved in an earlier section of the same debate was not found, so a suspension of standing orders was routed as a censure | `mover_finder_spec.rb` "when Hansard breaks the speeches after a move into pieces"; `context_builder_spec.rb` "finds the move behind a seconder and a reply that Hansard broke into pieces"; `speech_text_spec.rb` "carries whether Hansard records the speech as a new speech, an interjection or a continuation". The section was not the cause: at House 17 September 2026 #1 everything from the move (`uk.org.publicwhip/debate/2026-09-17.4.3`) to the division is under one heading and reached `MoverFinder`, but `UNNAMED_MOVE_WINDOW` counted Hansard's pieces, and the seconder's and the minister's speeches were 21 of them, broken at each interjection and point of order. The window now counts members' speeches: one starts at each piece Hansard marks `talktype="speech"`, or that has no talktype. Of the 910 divisions of 2026, 21 (8 House, 13 Senate) find a mover where they had none, and no other mover changes. Nine of them leave the fallback: four suspensions of standing orders reach Template 17 (House 3 March #1 and 17 September #1 settled, 14 September #5 and 15 September #2 offered), two references to committees settle 13 (Senate 31 March #8, 9 September #2) and two orders for documents settle 8 (Senate 13 August #5, 19 August #3). Senate 26 March #11 is offered Template 27 because its order mentions taking note of an explanation. Senate 9 September #2 was moved at another senator's request, which KI-65 covers. |
| KI-64 | Pipeline | 🟠 Medium | 🔴 Open | The model rarely pointed at the mover's reasons, leaving "About the Motion" empty | See the open entry below. |
| KI-65 | Pipeline | 🔵 Low | 🟢 Fixed | A motion moved at another senator's request is described as the mover's own | `context_builder_spec.rb` "finds whose notice it was when the mover says so" and "does not say a senator who moved an amendment to the notice moved it for its owner"; `template_compiler_spec.rb` "names whose notice it was when someone else moved it". A senator may move another's notice at their request (Senate S.O. 83(1), p. 61). The draft names the notice's owner, "on behalf of" as for KI-55, when the chair names them and the mover's own words do too: 69 of the 910 divisions of 2026, Senate 17 September 2026 #4 and #5 among them. Still open: a request the chair doesn't repeat (Senate 23 March 2026 #14), and an amendment moved at another's request (Senate 1 July 2026 #5), are not named. |
| KI-66 | Pipeline | 🔵 Low | 🟢 Fixed | A motion's lettered and numbered paragraphs were all quoted at one level, so "(i)" under "(a)" read as though it sat beside it | `quote_outline_spec.rb`; `template_compiler_spec.rb` "an outlined motion". Hansard's XML gives every paragraph as a flat `<p>`, so the depth comes from the labels: each new label style is one level further in, and going back to a style already open goes back to its level. "(i)", "(v)" and "(x)" are read as letters or numerals by what they continue. A paragraph without a label stays at the outer level. Only Motion Text is outlined, not the mover's quoted sentences. Checked on Senate 17 September 2026 #8, #9 and #10. |
| KI-67 | Pipeline | 🟠 Medium | 🟢 Fixed | The sitting-day retry had no limit on its size | `division_xml_spec.rb` "cuts the sitting day to its budget, nearest the division first, keeping the division's own debate". `DivisionXml#context_speeches` now cuts the sitting day's speeches to 100,000 characters, nearest the division first, but never cuts into the division's own debate, which the first call read whole; that debate's earlier moves still come from `EarlierDebate`. A limit on the tier covers the sitting-day packet built before the first call, when the question only refers to a motion Stage 1 could not find, as well as the retry. Over the 910 divisions of 19 January to 30 September 2026, from the cached XML on 21 October 2026: House 16 September 2026 #6's prompt fell from 453,534 characters to 109,516, with the same mover, and the largest from 517,377 to 210,157; no first-call prompt changed; 44 packets keep more of the same debate's earlier moves; 48 lose a proposer taken from a matter of urgency elsewhere that day; and Senate 26 March 2026 #12 loses a mover taken from another debate's third reading. House 25 June 2026 #4, a closure of a matter of public importance, now finds Template 17 as the debate cut short, from a 28 May suspension under another "Budget" heading; its sentence does not print it. |
| KI-68 | Rules | 🔴 High | 🟢 Fixed | Six question forms were routed as their opposites, so a draft would report the reverse of the vote | `procedural_router_spec.rb` "question forms that mean the opposite of the rule their words match". Each now falls to the general motion fallback: the previous question (Senate S.O. 94 and 95, p. 64) is kept from the closure rule, a reading "this day 6 months" (Senate S.O. 114(2), p. 71, and 122(3), p. 74) from the second and third reading rules, the committee's "without requests" and "subject to the requests" (Senate S.O. 140(3), p. 81) from the bill passing, "heard now" and "further heard" (House S.O. 65(c), p. 40, and 75(b), p. 43; Senate S.O. 196, p. 100) from Template 23, and the House's older "words proposed to be omitted stand part of the question" (House Guide p. 52) from the amendment rules. None of them is in the Hansard of 24 November 2025 to 17 September 2026, and none of the 910 divisions of January to September 2026 changed route. |
| KI-69 | Rules | 🔴 High | 🟢 Fixed | A Senate division without a quorum was reported as decided | `template_compiler_spec.rb` "flags a want of quorum against the Senate's 19" and "says nothing about a quorum when 18 senators voted". Senate S.O. 52(1), p. 43: a division showing "that a quorum is not present" decides nothing (S.O. 147(2), p. 84, in committee). The quorum is the standing orders' fixed 19 (p. vi), not a share of the members on the day. Exactly 18 votes is reported as the figures show: the President, or the Chair of Committees in committee, need not vote (S.O. 101(5), p. 67), so 18 votes may be 19 senators present. Odgers' Australian Senate Practice (14th edition, chapter 8, "Quorum") gives the same figure from the Senate (Quorum) Act 1991, "one quarter of the senators, that is, 19 out of 76 senators"; the Act's own text was not read. None of the 712 Senate divisions from 19 January to 17 September 2026 had fewer than 31 votes. |
| KI-70 | Rules | 🟠 Medium-High | 🟢 Fixed | Amendments a senator moved before a guillotine fell are described as moved by nobody, and three parts of the pipeline decide "nobody moved" differently | `context_builder_spec.rb` "credits the rest of a sheet's amendments to the mover the chair named earlier in the run, and only them"; `extraction_prompt_spec.rb` "does not tell the model nobody moved a question put under a limitation of debate"; `division_summarizer_spec.rb` "when a question put under a limitation of debate has no mover found". `ContextPacket#put_without_mover?` now decides it for the validator and the retry: no mover found, and a question that is the whole motion or amendments circulated and put. The prompt no longer tells the model nobody moved a question just because a limitation of debate applies. A guillotine alone no longer counts, since the chair first puts what was already moved (Senate S.O. 142(4), p. 82). A "moved by" earlier in the run counts only in a sentence naming this question's sheet. At Senate 18 August 2026 #14 the motion found is the whole sheet, including the two amendments division 13 had already decided. |
| KI-71 | Pipeline | 🟠 Medium | 🟢 Fixed | The prompt did not connect a House mover's name with the seat or office the chair calls them by | `extraction_prompt_spec.rb` "gives a House mover's seat and offices, which the chair calls them by", `member_resolver_spec.rb` "gives the offices the member held on the date". A House Member is referred to by office or seat, never by name (House S.O. 64, p. 40). A Senate mover is still given by name alone, since the Senate chair names senators. |
| KI-72 | Rules | 🟠 Medium | 🟠 Partly fixed | Senate rescission: the standing order and the guide disagree on the majority; the code's pattern was too broad | See the open entry below. |
| KI-73 | Rules | 🟠 Medium | 🔴 Open | Explainer and vote sentences that state one chamber's rule as general, or say more than the rules do (Templates 5, 7, 14, 25 and 26) | See the open entry below. |
| KI-74 | Rules | 🔵 Low | 🟢 Fixed | Three House rules the pipeline got wrong in rare cases: a tie on the ballot closure, the quorum fallback, and Template 1 | `template_compiler_spec.rb` "reports an equal vote on the ballot closure as lost", "takes the quorum from the seats, not the members on the day", "explains the first reading in the guides' own terms"; `procedural_router_spec.rb` "does not settle a House question on a first reading". A tie on "That the ballot be taken now" is lost (House S.O. 11(h), p. 17; House Guide p. 5). The quorum is 31 from 1 July 2019 to 3 May 2025 and 30 otherwise, whatever the member records say on the day (House Guide pp. 16 to 17, which foresees 151 Members "in the 46th Parliament"; S.O. 54, p. 37, 30 as at 23 July 2025). The 151 seats to 2025 rest on the member records, which give 151 on the first sitting days of the 2019 and 2022 Parliaments and 150 from the 2025 election; House of Representatives Practice and the Votes and Proceedings were not checked. The router no longer settles Template 1 for the House, where a bill is "read a first time without a question being put" (S.O. 141(a), p. 64), and the explainer no longer says such divisions are only "rarer" there. House S.O. 2 gives the count out as "currently 31 Members" (p. 7) against 30 in its quorum definition (p. 10) and S.O. 54; the 31 looks left over from the House of 151. |
| KI-76 | Pipeline | 🔵 Low | 🟠 Partly fixed | The Reviewer Only section left out things a reviewer needs; a local draft still does not name the reply it was built from | See the open entry below: three of its four points are fixed, each naming its spec. |
| KI-77 | Pipeline | 🔵 Low | 🟢 Fixed | The local model tools lose or misreport a reply that does not finish | `local_model_client_spec.rb` "saves the prompt even when the request times out", "fails when the model runs out of tokens before finishing", "says when the server's context ran out before max_tokens did". The prompt is saved before the request; a reply cut off for length is put down to the server's context when its `usage.completion_tokens` is below `max_tokens`, and to `max_tokens` otherwise, including when the server reports no usage. |
| KI-78 | Rules | 🔵 Low | 🟢 Fixed | Choices the pipeline made are not marked as choices, so they could be defended as rules or "fixed" as errors | Comments (no spec), citing KI-78 where the code makes each choice, and `ARCHITECTURE.md` section 8 for the template sentences. "X MP", the Monday deferral window, the divided question forms, the fallback constants, `MoverFinder`'s window, the validator's word lists and routing on the chair's question were already marked as the code's own or gave its reasons, so are unchanged. |
| KI-79 | Pipeline | 🔴 High | 🔴 Open | A draft said an amendment was agreed to when no amendment was moved or found, and passed validation | See the open entry below. |
| KI-80 | Pipeline | 🔴 High | 🟢 Fixed | A deferred vote the chair put by name, without restating its question, was drafted as a closure | `procedural_router_spec.rb` "locks out the closure when the chair only names a deferred vote". A question that names a deferred vote and matches no rule forbids Template 22, since the division is on the motion deferred (Senate S.O. 57(3), p. 47). When the motion deferred settles a route, that route is used as before, so a closure that was itself deferred is still a closure. Senate 5 March 2026 #8's motion matches no rule, so its route is still the general motion default. Of the 910 divisions from January to September 2026, only it and Senate 4 March 2026 #7, another deferred vote, changed route. |
| KI-81 | Pipeline | 🔵 Low | 🟠 Partly fixed | The deferral warning missed Senate wordings, and in both chambers fired on text that wasn't the chair's; a deferred vote put with no word of deferral is still missed | See the open entry below. |
| KI-82 | Rules | 🔵 Low | 🔴 Open | A draft can't say that its division was deferred from an earlier day, or that it replaced an earlier decision | See the open entry below. |
| KI-83 | Rules | 🔵 Low | 🟢 Fixed | The absolute majority was worked out from the members on the day, not the fixed figure the rules give: 38 in a Senate vacancy, and 75 in the House in March 2026 | `template_compiler_spec.rb` "does not lower the absolute majority during a vacancy". It is now always 76 in the House and 39 in the Senate. The rules give these as fixed figures ("Absolute majority 39", Senate standing orders p. vi; "more than half of all possible votes (39)", Senate Guide No. 3, p. 9; "currently 76 Members", House Guide p. 2). For the Senate, Odgers' Australian Senate Practice (14th edition, chapter 11, "Special majorities") says "No account is taken of any vacancy in the Senate in determining whether there is an absolute majority". For the House that is read from the quorum, also a share of the whole House, which "is not reduced by the death or resignation of a Member" (House Guide p. 17) (**Inferred**); House of Representatives Practice has not been checked on the absolute majority itself. |
| KI-84 | Pipeline | 🔴 High | 🟢 Fixed | A deferred second reading was credited to the mover of a second reading amendment negatived before it, and the amendment was printed as its motion | `mover_finder_spec.rb` "with a bill whose title says "Amendment"" and "with a reading moved long before its question". At House 5 March 2026 #1 the bill's title, "... Amendment Bill", made the second reading question look like one on amendments, which the amendment's terms fitted, so `MoverFinder` reads each bill's title as "bill" (`ProceduralRouter::BILL_TITLE`). For a question on a reading (the Senate's "that the second reading be agreed to" too, but not "that the second reading be made an order of the day"), `MoverFinder` takes the reading's own move ("That this bill be now read a second time") however far back in the debate it is given, never an amendment in its place. Of the 910 divisions of 2026, 5 change: House 5 March #1 and Senate 30 March #15 no longer credit a second reading amendment's mover; House 20 January #1 and Senate 5 February #1 now name the second reading's mover, and Senate 12 March #16 the third reading's, each checked against Hansard. |
| KI-85 | Rules | 🟠 Medium-High | 🔴 Open | A House division with six or fewer on a side (S.O. 127) may be reported as decided by no one, or the wrong way round | See the open entry below. |
| KI-86 | Pipeline | 🔵 Low | 🟢 Fixed | A unanimous division would read "a large majority" where the division page says "unanimously" | `division_facts_spec.rb` "says unanimously where the division page does" and `template_compiler_spec.rb` "says the chamber voted unanimously where the division page does". The vote sentence reads "the Senate unanimously voted for ..." (`SummaryWording#amount_with_article`). No 2026 division had an empty side, so no 2026 draft changes. |
| KI-87 | Pipeline | 🟠 Medium-High | 🟢 Fixed | A word such as "delayed" or "Committee" anywhere in a Senate second reading amendment switched off the validator's check of `declines_second_reading`, so whether the draft said the amendment opposed the bill rested on the model alone | `provenance_validator_spec.rb` "settles as not declining an addition that only mentions a delay or a committee, or has no opinion word" and "leaves an addition that refers or delays the bill to the model, and says so". `ProvenanceValidator::OPERATIVE_ADDITION` looks for the operative forms of a referral, a delay or a defeat ("the provisions of the bill be referred", "further consideration of the bill be made an order of the day"), and a Senate addition with none of them is settled as not declining, opinion word or not (Senate Guide No. 16, p. 47). Where the words leave the flag to the model, a warning says so. Of the 135 Template 2 drafts of 2026, 7 Senate ones are now settled by rule instead, each as the model had answered, and 78 carry the warning. Still worth knowing: an operative form the pattern doesn't list is settled as not declining, so a model that rightly answered `true` for it would fail validation. |
| KI-89 | Pipeline | 🔵 Low | 🟢 Fixed | Question Put gave the chair's question the time of the speech before it | `provenance_validator_spec.rb` "marks the time the chair's question takes from the speech before it as shared"; `template_compiler_spec.rb` "says the question was put before the division, at the time it shares, when that is not its own". The chair's statement putting the question shares the time of the speech before it at about two in three of the 985 divisions checked, from November 2025 to September 2026, so most drafts now say "Before the division, at" that time: the time a reader finds beside the chair's words in the record, which is how they find them. |
| KI-91 | Pipeline | 🔵 Low | 🟢 Fixed | Template 2's vote sentence says an amendment "introduced by" a senator "to the" bill, though amendments are moved, and a second reading amendment is to the motion | `template_compiler_spec.rb` "naming members of the House" and "amendments the chair put without anyone moving them"; `division_summarizer_spec.rb` "compiles a draft quoting only Hansard" (Template 4); the evaluation corpus. Templates 2, 3 and 4 now say "moved by"; motions keep "introduced by", the word the site's research guide uses ("Who introduced the motion and why?"). |
| KI-92 | Rules | 🔵 Low | 🔴 Open | A senator's position on parts of a question, recorded by leave just after its division, never appears in a draft: a decision is needed | See the open entry below. |
| KI-93 | Rules | 🔵 Low | 🟢 Fixed | Template 8's explainer tells the reader what "the summary should not suggest", calls a Senate order a power of "the parliament", and doesn't say the documents become public only when tabled | `template_compiler_spec.rb` "Template 8, an order for the production of documents", "names the chamber, says tabled documents become public, and gives the writer no instruction". The writing instruction is gone, and the explainer says the order is the chamber's (Senate S.O. 164(1), p. 90; House S.O. 200, p. 84, since the router does not limit Template 8 to the Senate), that it makes the government table the documents, that an order usually sets a deadline (Senate Guide No. 10, p. 25), and that tabled documents become public (Guide No. 10, p. 26; House S.O. 203, p. 85). |
| KI-95 | Pipeline | 🟠 Medium | 🟢 Fixed | A motion Hansard set in a plain paragraph after "I move:", instead of in italic, was not read as a move | `speech_text_spec.rb` "reads a motion Hansard set in a plain paragraph straight after "I move:"" and "takes only one whole motion from plain paragraphs". 8 of about 1,850 "I move:" paragraphs in the 2026 Hansard are followed by a plain paragraph. At House 2 July 2026 #6 the Leader of the House's "That the member be no longer heard." (`uk.org.publicwhip/debate/2026-07-02.108.1`) was missed, so the division had no mover; it now has. At Senate 5 March 2026 #3, #4 and #6, on amendments to the motion "That the report be adopted.", that motion is now read as one, and reaches the packets of #4 and #6 as earlier debate. A plain paragraph doesn't show where a motion ends, so only one is taken, and only when it starts "That" and doesn't end in a colon or dash introducing parts to follow. Still open: a motion whose parts follow in plain paragraphs is not read, such as the Senate's "Omit all words after "That", substitute:" and its paragraphs (a) to (c) (`uk.org.publicwhip/lords/2026-03-04.185.1`); the next division that day is under another heading. |
| KI-96 | Rules | 🟠 Medium | 🟢 Fixed | "the remaining stages of the bill be agreed to and the bill now be passed" fell to the general motion fallback | `procedural_router_spec.rb` "routes the remaining stages with 'now be passed' to Template 6". KI-31's question in another word order: `ProceduralRouter#third_reading` looked for "be now passed", not "now be passed", so at Senate 12 March 2026 #24 a draft would not say the bill passed. Both forms are now accepted. |

---

## Open: rules

### KI-4

**Real question forms fall through to Template 15.** Severity: High. Status: **Partly fixed**.
**Confirmed** by running each form through `ProceduralRouter.route`.

Template 15 is the fallback. "That the bill be considered urgent" now routes to Template 18, and
Template 15 no longer claims every question it receives "records an opinion ... and has no legal
effect". These forms still land there with no template that fits them:

| Question form | Source | What it actually is |
|---|---|---|
| "That the bill stand as printed" | Senate Guide No. 16 | The final question in committee of the whole when no amendments were agreed to. |
| "That the bill (as amended) be agreed to" | House S.O. 150(c), 153(a), Guide p. 72-73 | End of consideration in detail, or the report stage for a bill from the Federation Chamber. |
| "That the report of the committee be adopted" | Senate Guide No. 16 | Report from committee of the whole; amendments are moved to it. |
| "That the proposed expenditure(s) be agreed to" | House Guide p. 82 | The appropriation bill detail stage. |
| "That the House approves the form of agreement ..." | House Guide p. 94-95 | Approval of a legislative instrument, the mirror of disallowance. |

Each needs its own template, which adds to the catalogue: a decision to agree with a human before
writing, not a change to make unilaterally. New templates are numbered after the last one (as
Template 29, the second reading, was) so that no template already cited by number moves.

This entry also listed "That the words proposed to be omitted stand part of the question". That
form never reaches the fallback: it is settled on Template 2, the opposite of what it decides, so it
is now in KI-68 with the other inverted forms.

### KI-13

**Template 2 describes the four things a stage amendment can do, but not which one this was.**
Severity: Low. Status: **Partly fixed**.

Senate Guide No. 16 (p. 47) lists four things such an amendment may do: express an opinion,
reverse the motion so the bill is defeated at that point, refer the bill to a committee, or delay
further consideration. The explainer now lists all four. The guide does not say the list is
complete, and Senate S.O. 114(3) allows "Other amendments ... provided that they are relevant to
the bill", so the "closed list" this entry used to describe was its own reading. Still open:
extracting which one applies, as a choice from the four with an "other" answer, so the summary
can say which. Worth doing once the evaluation corpus has enough Template 2 divisions to
tell whether the model gets it right. Two things to know while working here: a referral can arrive
as a second reading amendment (Senate S.O. 114(3)), and the second reading amendment on the main
appropriation bill is conventionally cast as a censure of the Budget (House Guide p. 81-82). This
entry used to say the router handled that because the second reading rules came before Template 10;
they did not, and such an amendment read out as the question was settled as a censure until
`reasoned_amendment_form` was put before the subject rules in September 2026
(`procedural_router_spec.rb` "routes a Budget amendment worded as a censure to Template 2").

### KI-18

**A tied House division cannot be resolved from the recorded figures.** Severity: Medium.
Status: Open.

In the Senate an equally divided question is lost (Constitution s 23, Senate Guide No. 3). In the
House the occupant of the Chair has a casting vote under s 40, which decides the question and is
not in the aye and no counts. The summary now reports a tied House division as "not decided by the
division figures, which were equal" and says the figures do not record the casting vote. Recovering
it means reading the Votes and Proceedings, where S.O. 135(c) requires the Speaker's reasons to be
recorded, and TVFY does not load that.

"The occupant of the Chair" overstates who has the casting vote. House S.O. 3(d), pp. 11 to 12:
"The power to exercise a casting vote (standing order 135) is reserved for the Speaker, Acting
Speaker, Deputy Speaker or Second Deputy Speaker", and the House Guide (p. 58) adds that it "does
not apply to members of the Speaker's panel in the Chair unless specifically appointed by resolution
of the House as Acting Speaker". The same words are in `SummaryWording#result_notice` and the
comment on `ParliamentaryOutcome#tied?`. S.O. 135(c) records the Speaker's reasons, if given; the
decision itself is in the Votes and Proceedings (S.O. 27), and the Chair announces it in the House,
so Hansard after the division may be enough to recover it. **Verify** that, and that a casting vote
is not in TVFY's aye and no counts: no tied House division is in the 2026 data.

### KI-19

**Template 21 cites the Parliament Act 1974, which neither guide mentions.** Severity: Low.
Status: **Verify**.

The House guide confirms works in the parliamentary precincts can be subject to parliamentary
approval (p. 117) but names no Act, and the Senate guides do not cover it. The citation is probably
right and was left in, but it has not been checked against a primary source.

### KI-50

**A motion that says its parts "operate as limitations of debate under standing order 142" is
routed to Template 18 only as advice.** Severity: Medium-High. Status: **Partly fixed**.
**Confirmed** from four local models' drafts on 1 October 2026 and from the code.

Fixed: a motion whose first paragraph Hansard sets as "That—" alone was routed on that one word, so
the Senate's order fixing a week's hours and guillotines fell to the general motion fallback.
`ContextBuilder#operative_paragraph` now reads every paragraph after a bare "That"
(`context_builder_spec.rb` "routes a motion whose first paragraph is only \"That\" on the
paragraphs after it"). Only Senate 18 August 2026 #2 moved in the 121 loaded divisions.

Still open: the route that gives is advisory. That order's paragraph (4) reads "Paragraphs 1(b) and
(c), 2(b) and (c), and 3(c) operate as limitations of debate under standing order 142." A route
taken from the motion text binds only when the motion opens in a fixed form
(`ProceduralRouter.fixed_opening?`), which protects against a misleading first paragraph, and this
one opens with "That" alone. Three of four local models chose Template 19 instead. Both templates
are true of the motion, but only 18 says debate was limited, and only its title reads "; Limitation
of Debate". Senate Guide No. 17 (p. 51) supports 18: "the application of a time limit to the
consideration of a bill is referred to as a guillotine", and "Guillotine motions are often moved as
part of broader motions varying the days and hours of sitting". Whether a motion's own "limitations
of debate under standing order 142" should settle or fence the route, as a named exception to the
rule that motion text is only advice, is a decision for the team. Test in
`procedural_router_spec.rb`, with a route snapshot before and after.

### KI-52

**Some forms of a question put when a debate's allotted time has expired are not recognised.**
Severity: Medium. Status: **Partly fixed**. **Read** (the House form); **Verify** (the Senate form
and the House's urgent-bill wording).

Fixed: a House question put "immediately" under a resolution agreed earlier is found by rule like
the Senate's statement, walking back through the run of divisions (`division_xml_spec.rb` "finds
the Speaker putting the question immediately under a resolution, across the run of divisions";
`template_compiler_spec.rb` "a question the House put immediately under a resolution agreed
earlier"). It is kept as its own kind: the House programming a bill by suspending standing orders
is not a guillotine (House Guide p. 75), so the draft says "This question was put without further
debate, under an arrangement the House of Representatives agreed on 12 August 2026", the date from
the Speaker's words, and quotes them. The Speaker saying "In accordance with the resolution agreed
to on 23 June 2026, the time allotted for this debate has expired." is read the same way (House 24
June 2026 #1, `division_xml_spec.rb` "finds the Speaker saying the time a resolution allotted has
expired").

Still open:

- House 24 June 2026 #2 is still missed. The Speaker put it with "The question before the House is
  that the bill be read a second time." (`uk.org.publicwhip/debate/2026-06-24.112.1`), which
  `DivisionXml::CHAIR_STATEMENT` does not take for the chair's, and the Deputy Speaker had said the
  time expired, so the walk back from #2 takes the Speaker for a second member and stops. "The
  question before the House is" occurs 31 times in the House's 2026 Hansard, and
  `ChairStatement::QUESTION` does not read it either, so this is wider than this entry.
- "In accordance with the resolution agreed to earlier, the time allotted for this debate has
  expired" (before House 30 March 2026 #1, 31 March 2026 #1 and 23 June 2026 #2:
  `uk.org.publicwhip/debate/2026-03-30.120.2`, `2026-03-31.105.2`, `2026-06-23.93.15`) gives no date.
  `SummaryWording#limitation_lead` names the resolution by its date and, without one, calls the
  question a guillotine, so a fix needs a sentence for a resolution without a date: a wording
  decision.
- In the Senate on 25 June 2026 the chair said "Pursuant to order agreed to on Tuesday ... I'm now
  required to put the questions", with no "time allotted ... has expired". Senate Guide No. 17
  (p. 51) allows a guillotine to set "a set time in a day (e.g. 'all remaining stages to conclude by
  5 pm today')" rather than a duration, so this form is expected. **Verify** it on more sitting days
  before adding it; KI-36 is the Senate statement it would extend.
- What the Speaker says under the House's own guillotine for urgent bills (S.O. 82 and 85) has not
  been seen in any sitting day checked, so it stays **Verify** before this is extended to it.

### KI-72

**Senate rescission: the standing order and the guide disagree on the majority.** Severity: Medium.
Status: **Partly fixed**. **Read** (code); **Verify** (the threshold).

Senate S.O. 87, p. 62: an order "may be rescinded, but not during the same session unless 7 days'
notice is given and at least one-half of the whole number of senators vote in favour", which is 38
of 76. Senate Guide No. 3, p. 9, says rescission needs an absolute majority, which "is more than
half of all possible votes (39)". The standing order is the rule and the guide explains it, so the
threshold should be 38, and only within the same session. The standing order's exception, "to
correct irregularities or mistakes one day's notice shall be sufficient", shortens the notice and,
on its words, leaves the majority as it is. How the Senate applies S.O. 87 should be checked in
Odgers' Australian Senate Practice before the threshold changes.

Fixed: `ParliamentaryOutcome#absolute_majority_requirement` returned `:always` for any Senate motion
whose words included "rescind", "rescinded" or "rescinding", so a motion calling on the Government
to rescind its own decision was flagged as needing a special majority. It now takes only a motion
that an order, resolution or vote "be rescinded" (`template_compiler_spec.rb` "flags a Senate
rescission carried without an absolute majority, but not a call on the government to rescind").
No Senate motion from November 2025 to September 2026 used either form, so no draft changes.

### KI-73

**Explainer and vote sentences that state one chamber's rule as general, or say more than the rules
do.** Severity: Medium. Status: Open. **Confirmed** against the rules named, and by running the
router where a route is involved.

Each is a wording change in a template or in `summary_wording.rb`, except where the last column
says a decision is needed:

| Where | What it says | What the rules say | Change |
|---|---|---|---|
| Template 5 (Federation Chamber report) | the questions on the report are "put immediately, without debate or amendment" | House S.O. 153(b)(i), p. 68: on a bill reported with unresolved questions, "A separate question shall be proposed on each unresolved question and each shall be open to amendment or debate". Only 153(a), (b)(ii) and (b)(iv) are decided without | Correct the sentence. An amendment question under a "; Report from Federation Chamber" heading routes to [2, 4], so Template 5 cannot be chosen for the questions that actually divide there: whether to allow it is a catalogue decision |
| Template 26 (adjournment), in the Senate | "At a set time each sitting day the chair proposes that the chamber do now adjourn" | Senate S.O. 54(5), p. 44: "The President shall adjourn the Senate without putting the question"; S.O. 53(2), p. 43: the adjournment may be moved "by or on behalf of a minister", so a Senate adjournment division only comes from a minister's motion | A Senate sentence citing both |
| Template 25 (dissent) | "Dissent can only be moved against a ruling", with no chamber named | That is the House (House Guide p. 42: decisions "at the Speaker's discretion are not rulings and cannot be dissented from"). Senate S.O. 198(1), p. 101: an objection may be taken "to a ruling or decision of the President", and S.O. 198(2) adjourns its debate to the next sitting day unless the Senate decides otherwise | Label the sentence House-only and add a Senate one, without claiming every decision can be challenged, since Odgers' may limit it |
| Template 14 (Selection of Bills) | the committee "decides which newly introduced bills need to be sent to other committees"; an amendment to the motion adopting its report is settled on 14 and printed as voting on "a motion ... to adopt the report" | Senate S.O. 24A(1), p. 26: the committee reports on bills to be referred; Senate Guide No. 13, p. 34: it "makes recommendations to the Senate about bills to be referred", and adopting the report does the referring | "recommends", and a vote sentence for an amendment |
| Template 7 and `SECTION_53_NOTE` | section 53 "stops the Senate amending a bill at all", naming only tax and ordinary annual services bills | House Guide p. 88 and Senate Guide No. 16, p. 49: the Senate also may not amend a bill "so as to increase any proposed charge or burden on the people", though the House Guide (p. 89) says what that covers has not been "conclusively determined" | Add the limb, carefully |
| Template 7, the effect of a message vote | "goes back to it for further negotiation" and "proceeds without them" | House: a return to the Senate goes through a motion with written reasons and "That the reasons be adopted" (S.O. 161(c), p. 70), and S.O. 162 and 169 (pp. 70 to 72) leave the House other courses, such as further or alternative amendments, laying the bill aside, or insisting. Senate: not insisting "and" making alternative amendments in their place is not "proceeds without them" (Senate Guide No. 18, p. 54), and a bill may be laid aside (S.O. 126(6), p. 75) | Neutral wording for the House until a source says more, and detect the compound "not insist" forms before printing an effect. KI-2's omit-clause case is separate |

### KI-82

**A draft can't say that its division was deferred from an earlier day, or that it replaced an
earlier decision.** Severity: Low. Status: Open. **Read**, from Hansard and the drafts.

A Senate division called after the cut-off "shall be taken on the next day of sitting, at a time
fixed by the Senate" (Senate S.O. 57(3), p. 47), and in 2026 some were taken weeks later: Senate
4 March 2026 #7 decided a motion moved on 5 February (`uk.org.publicwhip/lords/2026-03-04.142.3`).
A question can also be put again by leave and divided on afresh (Senate Guide No. 3, p. 9, on
divisions "held again by leave"; S.O. 88, p. 62): Senate 16 September 2026 #12 negatived a general
business motion that Hansard records as "Question agreed to." 38 minutes earlier
(`uk.org.publicwhip/lords/2026-09-16.142.2`, recommitted by leave at 165.2 after a party's mistake
in its directions). Both drafts report the right result. Neither says when the motion was moved,
or that an earlier decision was replaced, and no template has a place to, so a reader can take a
month-old motion for that day's. `EarlierDebate` already has the date of the move. Whether drafts
should say so is a catalogue decision.

The House is the same. Its eight deferred divisions of 2026 (10 February #1, 5 March #1, 14 May
#1, 28 May #1 to #4, 19 August #1) were put on the next sitting day "without amendment or further
debate" (House S.O. 133(d), p. 60), and no draft says the vote was deferred. The House also replaces
a division: after "That the House divide again", "the result of the subsequent division shall be the
decision of the House" (S.O. 132(b), p. 60). The division that miscarried stays in TVFY and would be
drafted as a decision. None in 2026.

### KI-85

**A House division with six or fewer on a side is not handled.** Severity: Medium-High. Status:
Open. **Inferred** from the code and the standing order; **Verify** how such a division reaches
They Vote For You.

House S.O. 127 (amended 23 July 2025, p. 58): "If, after the doors are locked, there are six or
fewer Members on one side in a division, the Speaker shall declare the decision of the House
immediately, without completing the count. The names of the Members who are in the minority shall
be recorded in the Votes and Proceedings." The House Guide (p. 56) still says "four or fewer".
Nothing in the pipeline knows this rule. If the record of such a division lists only the minority,
its turnout is six or fewer, `ParliamentaryOutcome#want_of_quorum?` is true, and the draft says the
question was "not decided, because fewer than a quorum of members voted": a decision the House made,
reported as never made. `Division#passed?` would also read the result from a one-sided count, which
may be the wrong way round. No 2026 House division had six or fewer on a side, but six had seven
(for example House 11 March 2026 #2 and #5, and 4 June 2026 #12). First check how Hansard, the
openaustralia-parser and the loader record one. A fix would treat a one-sided House count of six or
fewer as S.O. 127 rather than want of quorum, take the result from the Chair's declaration after the
division, and say so. Test in `template_compiler_spec.rb` "constitutional and parliamentary
procedures".

### KI-92

**A senator's position on parts of a question, recorded by leave just after its division, never
appears in a draft. Whether it should is a decision for the team.** Severity: Low. Status: Open.
**Read**.

At Senate 14 September 2026 #8 Senator Payman voted no, then said "by leave—In the interest of time,
I ask to have my support recorded for parts (a), (b)(i) and (b)(iv)"
(`uk.org.publicwhip/lords/2026-09-14.41.1`). The draft says "Nobody voted against their party on this
occasion", true by the record, and nothing of her stated support for three of the amendment's five
parts. Senate Guide No. 3, p. 8, provides for a vote recorded by leave instead of a division ("A group
of senators voting against a motion may have their vote recorded in the Journals, by leave, as an
alternative to a division"); a statement after a division, qualifying the senator's own vote in it,
is not described in the standing orders or guides read for this entry. It is not a vote, and must not
be counted or called a rebellion. `DivisionXml::POSITION_RECORDED` already recognises such statements,
but only to walk past them when looking for a guillotine, and the context ends at the division, so
they never reach a draft.

A decision is needed, not a fix: whether a draft should note such a statement, in Hansard's words and
with no count. If it should, the tests belong in `division_xml_spec.rb`, for finding the statement
after the division, and `template_compiler_spec.rb`, for the note.

## Open: pipeline

### KI-29

**Findings from the same audit.** Severity: Medium. Status: **Partly fixed**. Recorded as
**Read** when found: each was reported with a file reference but not reproduced.

Fixed by the "the model selects, it never writes" redesign (`docs/adr/0005-ai-summaries-select-never-author.md`),
each guarded by the spec named:

- A reply in the old title and description shape was saved without Stage 4. There is now one
  reply schema and no legacy path: `extraction_payload_spec.rb` "does not accept a reply in the
  old title and description shape", `division_summarizer_spec.rb` "when the model answers in the
  old title and description shape".
- "Amendment" in a bill's title triggered the amendment rule: `procedural_router_spec.rb` "a bill
  title that contains the word amendment", corrected by KI-30.
- An unverifiable `motion_text` was only a warning. The motion is now Stage 1's, or a model
  reference that resolves, and a question that only refers to a motion nobody can find is a hard
  error: `provenance_validator_spec.rb` "the operative motion".
- A draft with no claims published "[No explanatory claims recorded]", and the claim cap was not
  enforced. The section now reads "No explanatory claims recorded.", and at most six sentences are
  quoted: `provenance_validator_spec.rb` "quotes at most six sentences, the first ones spoken",
  `evaluation_spec.rb`.
- Every mover's statement was dated with the division's time. Each quote now carries its own
  speech's time: `template_compiler_spec.rb` "quotes each passage under the time of the speech and
  the mover's name".
- Claims were the model's paraphrase set as quotations. There are no claims any more, only
  Hansard's own sentences retrieved by reference: `provenance_validator_spec.rb`,
  `reviewer_report_spec.rb` "contains nothing the model wrote".
- The draft title was the model's `topic`. It is built by rule from the heading and the template:
  `draft_title_spec.rb`.
- The Senate's Template 2 explainer described only the House: `template_compiler_spec.rb`
  "Template 2's explainer in each chamber".
- "Large majority" meant any majority over half the turnout. The draft now uses the division page's
  thresholds, repeated from `DivisionsHelper` because the helper builds HTML:
  `division_facts_spec.rb` ".majority_strength".

Still open:

- No draft says it was drafted with AI or by which model. The Reviewer Only report records the
  model for reviewers, but that section is removed before publishing. How a published summary
  should say so is a decision for the team, since drafts are meant for the public site.

### KI-58

**Models still pick remarks aimed at other members as the mover's case on some divisions.**
Severity: Medium. Status: **Partly fixed**. **Confirmed** from four local models' drafts on
1 October 2026.

Fixed in the prompt: rule 5 asks for sentences about the motion, the bill or the policy, not about
other members or parties or addressed to them, and says an empty list is the usual answer for
Template 17, whose scope the team kept as "why the rules should be set aside, not the merits"
(decided by Blake, 30 September 2026; `extraction_prompt_spec.rb` "asks for the case rather than
remarks aimed at others, and says Template 17 usually has none"). The Reviewer Only report lists
quoted sentences that say "you" or name another member, as a prompt only (`reviewer_report_spec.rb`
"flags a quoted explanation that speaks to someone or names another member").

Still open: the rule worked at Senate 12 August 2026 #4, where no model picked the remark aimed at
others this time, but not at Senate 20 August 2026 #23, where three of four models still picked a
sentence addressed to "you", and one also picked a sentence about another member that names nobody
(KI-76). On Template 17, three of four models followed the rule; the fourth had run out of its
reasoning budget. Whether models choose better can only be judged on real output: **Verify** with a
Bedrock run on those two divisions, compared by a person before and after. KI-64 may be the other
side of the same rule: a model too cautious to quote anything.

### KI-61

**Sentences left out between quoted ones are not marked.** Severity: Low. Status: **Open, deferred
by decision** (Blake, 30 September 2026), to be thought about further and reviewed.

When the explanation quotes sentences that are not consecutive in Hansard, `EvidenceSections` prints
them as separate blockquotes, which is the only sign of a gap. Nothing tells a reader that sentences
between them were left out, and a reader could take them for consecutive: at House 18 August 2026 #3
one model quoted S2.118 to S2.120, S2.122 and S2.124, three of them one paragraph in Hansard. The
options considered were a "[...]" line between non-adjacent passages, "(sentences omitted)", or
leaving them as they are, which was chosen for now. Any of them is template text, so it does not
affect ADR 0005. When this is revisited, the place to change is `EvidenceSections#explanation`, and
`Transcript#passages` already says where one passage ends and the next begins.

### KI-64

**The model rarely pointed at the mover's reasons.** Severity: Medium. Status: Open. **Verify**
against Hansard before changing anything.

Over the 12 drafts that compiled on 12 October 2026, Qwen3.6-35B-A3B (UD-Q4_K_M) gave explanation
references for one (Senate 17 September 2026 #8), so the other 11 print "No explanatory claims
recorded." Some of those votes may have had no debate to quote, such as rearranging business, a
third reading and an item standing as printed, and for those an empty section is right. Not yet checked:
whether the second reading amendments at Senate 17 September 2026 #9 and #10 had speeches giving
reasons that the model should have quoted. If they did, KI-58's wording in the prompt, which asks
for the case rather than remarks aimed at others, may have made the model too cautious.
Senate 17 September 2026 #9 and #10 are among the second reading amendments moved straight after
another division, where the mover's earlier speech never reaches the model (KI-90), so check them
against that cause first.

### KI-76

**The Reviewer Only section leaves out things a reviewer needs.** Severity: Low. Status: **Partly
fixed**. **Confirmed** from drafts, except where marked.

Still open: a draft from `rake ai:draft_local` does not name the saved reply it was built from, or
say whether that reply was cut off, so matching a draft to its reply means opening the saved
prompts. The reply files are named by database id, which differs between machines.

Fixed (`reviewer_report_spec.rb`):

- The "Mover" table had no row for an urgency motion's proposer, so a reviewer could not see where
  "on behalf of Senator ..." came from. It now has a "Proposer" row ("names who proposed what
  someone else moved, and only when someone did").
- "Explanation sentences to look at twice" (`ReviewerReport::POINTED`) looks for "you", "Senator X",
  "member for X", "Prime Minister" or "Minister X", so at Senate 20 August 2026 #23 it missed a
  sentence that described another member without naming them. No pattern can catch every such
  phrase, so the list now says it is a prompt for the reviewer, not a complete check ("flags a
  quoted explanation that speaks to someone or names another member, for the reviewer only").
- The "Title" row quoted the heading as stored on the Division record, such as "Securing the Ndis
  for Future Generations", though the draft's own title reads "NDIS" (KI-48). It now prints a
  bill's title in the heading as the title does ("quotes the heading with the bill's title as the
  title prints it").

### KI-79

**A draft said an amendment was agreed to when no amendment was moved or found, and passed
validation.** Severity: High. Status: Open. **Confirmed** from the draft.

At House 16 September 2026 #6 the question was "The question is the bill be agreed to.", the final
question of consideration in detail (KI-4). The model chose Template 4, an amendment template,
though Stage 1 found no mover and no terms, and the model gave no motion references and reported
"operative_motion" missing. The draft's title ended "Consideration in Detail Amendment", and it said
"a small majority voted for an amendment to the [bill] during the Consideration in Detail stage,
which means it was successful. The text of the bill has been changed accordingly." The last
sentence is `SummaryWording#amendment_effect_clause`, which Templates 3 and 4 print when the vote
succeeds. `ProvenanceValidator` recorded no errors, only the warning that the model had reported the
terms missing, so an editor would see a plausible draft saying this vote amended the bill.

Nothing compares the kind of template chosen with the evidence found. An amendment template with no
terms, no amendments circulated and no mover is the case to catch. A fix belongs in
`ProvenanceValidator` and would be tested in `provenance_validator_spec.rb`. Whether it fails the
draft or only warns the reviewer is a decision to agree first.

### KI-81

**A deferred vote the chair puts with no word of deferral raises no deferral warning, and the
warning reaches questions put after the deferred ones in the same run.** Severity: Low. Status:
**Partly fixed**. **Confirmed** by reading each division's run of chair's statements over the 910
divisions from January to September 2026, before and after the fix, on 21 October 2026.

Fixed: `#deferred_by_chair?` read every speech in the packet, so a motion's own terms (Senate 4
March 2026 #4, "the deferred vote", `uk.org.publicwhip/lords/2026-03-04.23.1`; House 18 August 2026
#10, "standing order 133(b) (deferred divisions) being suspended") and, on the sitting-day retry,
any deferred vote put earlier in the day raised it. It now reads only the chair's statements in the
division's run (`DataLoader::DivisionXml#run_statements`, which ends with the one putting this
question), and `DEFERRED_STATEMENT` allows words between "division" or "votes" and "deferred", as at
Senate 3 March 2026 #2 ("a division on amendment (1) on sheet 3472 moved by Senator Shoebridge was
deferred") and 20 August 2026 #14 and #15 ("the votes on the amendments moved by Senator Shorebridge
and Senator Bell were deferred"). `context_builder_spec.rb` "reads the Senate chair's deferral with
words between the vote and "deferred"" and "does not read a deferral from the terms of the motion
being put". The default packet now warns at those three and at 20 August #16 and #17 (below), and
no longer at 4 March #4; the sitting-day retry warns at the same 25 divisions, not 109.

Still open:

- A deferred vote the chair puts with no word of deferral is not seen: Senate 25 March 2026 #1
  ("The question is that the amendment moved by Senator Waters be agreed to.",
  `uk.org.publicwhip/lords/2026-03-25.17.3`, deferred at `2026-03-23.216.2`), and Senate 4 March
  2026 #9, on a motion whose division was deferred on 3 March (`2026-03-03.168.1`). The Senate
  takes such a division "at a time fixed by the Senate" (S.O. 57(3), p. 47), so there is no time
  window to fall back on; only the earlier day's statement deferring it shows it.
- Only the first question of a run says it was deferred, so the warning is carried along the run
  (KI-6), and at Senate 20 August 2026 #16 and #17 it reaches questions that were not deferred: the
  chair put the two deferred votes first (`2026-08-20.65.2`, "I will put those questions first
  before dealing with the remaining amendments") and the rest under the limitation of debate, which
  has its own warning.

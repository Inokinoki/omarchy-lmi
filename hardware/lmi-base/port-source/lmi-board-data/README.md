# lmi board data (audio) — PENDING (M2)

The POCO F2 Pro uses the same WCD9380 codec family as apollo but a different
speaker amplifier: NXP TFA9874 on i2c3 instead of two Cirrus CS35L41 parts.
The apollo port's audio deliverables (ALSA UCM for `Xiaomi-Mi-10T`, the
PCM-format override and the Cirrus smart-amp firmware) therefore do not
transfer and are deliberately absent here.

What is known from the community mainline work, to use as the starting point
when the UCM is written:

- sound card `qcom,sm8250-sndcard` with WCD9380 via Soundwire;
- a capture-side quirk requiring `<&swr2 1>` as the second Soundwire port;
- an inverted earpiece PA (EAR_PA) polarity;
- speaker and earpiece through the TFA9874 on i2c3, microphones through the
  WCD9380.

Deliverables expected in this directory once audio is brought up: a UCM2
topology (`HiFi`, `VoiceCall` as applicable) named for the lmi sound card,
plus any PCM-format overrides the WCD9380 path needs. Nothing in this
directory claims tested behavior.

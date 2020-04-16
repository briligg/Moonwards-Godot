extends Node
class_name AudioSignals

#This signal is emiited when an audio player that is meant to be
#playing by itself with no other solo audio player has started.
const SOLO_AUDIO_STREAM_BEGUN : String = "solo_audio_stream_begun"
const SOLO_AUDIO_STREAM_ENDED : String = "solo_audio_stream_ended"
# Define the actual signal.
#warning-ignore:unused_signal
signal solo_audio_stream_begun()
#warning-ignore:unused_signal
signal solo_audio_stream_ended()

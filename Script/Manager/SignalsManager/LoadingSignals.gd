extends Reference
class_name LoadingSignals

const name = "Loading"

# When the world node's `_ready` is called.
const WORLD_ON_READY: String = "world_on_ready"
signal world_on_ready()

# Happens one frame after the world's node `_ready` is called.
const WORLD_POST_READY: String = "world_post_ready"
signal world_post_ready()

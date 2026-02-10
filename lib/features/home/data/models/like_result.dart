enum LikeResult {
  newLike,      // First time liking, no mutual match yet
  mutualMatch,  // First time liking, created a match
  alreadyLiked, // User was already liked before
  error,        // Something went wrong
}

var tagId = "course-youtube-player";

export function initPlayer(courseId, studentId) {
  var tag = document.createElement('script');
  tag.id = tagId
  tag.src = "https://www.youtube.com/iframe_api";
  tag.dataset.courseId = courseId
  tag.dataset.studentId = studentId
  document.head.appendChild(tag);
}

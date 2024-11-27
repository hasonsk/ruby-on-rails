document.addEventListener("turbo:load", function() {
  document.addEventListener("change", function(event) {
    let image_upload = document.querySelector('#micropost_image');
    const size_in_megabytes = image_upload.files[0].size/1024/1024;
    if (size_in_megabytes > Settings.default.micropost_image_max_size) {
      alert(t("micropost.maximum_file_size_is_5mb"));
      image_upload.value = "";
    }
  });
});

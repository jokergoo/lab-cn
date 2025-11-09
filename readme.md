
Hugo主题相关文件

全局css样式：

- `themes/hugo-back-and-light-theme/layouts/partials/styles.html`

页面的header和footer：

- `themes/hugo-back-and-light-theme/layouts/partials/header.html`
- `themes/hugo-back-and-light-theme/layouts/partials/footer.html`

页面的主体：

- `themes/hugo-back-and-light-theme/layouts/\_default/single.html`

文章列表：

- `themes/hugo-back-and-light-theme/layouts/\_default/list.html`

所有生成的链接均需为小写

R markdown或者markdown文件放在`content/`目录下。`content/path/filename.Rmd`会生成`/root/path/filename/`链接。

所有图片放在`content/image`目录下，在markdown文件中使用图像的路径时（无论markdown文件在哪儿），都使用`image/...`形式。

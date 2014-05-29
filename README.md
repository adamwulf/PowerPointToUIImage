# PowerPoint slide thumbnails

This is a sample project to show how to generate thumbnail UIImages for each slide of a .ppt file.

The basic idea was expanded on from an answer in stack overflow: http://stackoverflow.com/questions/15971969/ios-library-to-convert-powerpoint-presentations-into-images

Many thanks to Ram (http://stackoverflow.com/users/1067951/ram) for his suggestion.

# Notes

1. Since this happens in a UIWebView, all of this happens on the main thread
2. Smaller thumbnails will have a smaller memory footprint when generating - lots of large thumbnails could be bad!
3. Making extremely small thumbnails might screw up the offsets in the webview, generating offset slides
4. Thanks for taking a look!

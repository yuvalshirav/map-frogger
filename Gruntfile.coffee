module.exports = (grunt) ->

  require("load-grunt-tasks")(grunt)
  require("time-grunt")(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    paths:
      docs: "docs"

      src:
        root: "src"
        app: "<%= paths.src.root %>/app"
        images: "<%= paths.src.root %>/images"
        styles: "<%= paths.src.root %>/styles"

      dist:
        root: "dist"
        app: "<%= paths.dist.root %>/app"
        images: "<%= paths.dist.root %>/images"

      tests:
        root: "test"
        unit: "<%= paths.tests.root %>/unit"
        functional: "<%= paths.tests.root %>/functional"

    mince:
      app:
        options:
          enable: ["source_maps"]
          sourceMappingBaseURL: "../"
        files: [
          src: "<%= paths.src.root %>/javascript.coffee"
          dest: "<%= paths.dist.root %>/app.js"
        ]

      test:
        files: [
          src: "<%= paths.tests.unit %>/test.coffee"
          dest: "<%= paths.tests.unit %>/test.js"
        ]

    uglify:
      production:
        files:
          "<%= paths.dist.root %>/app.min.js" : "<%= paths.dist.root %>/app.js"

    clean:
      dist: "<%= paths.dist.root %>"
      images: "<%= paths.dist.images %>"
      docs: "<%= paths.docs %>"

    imagemin:
      compile:
        options:
          cache: false
        files: [
          expand: true
          cwd: "<%= paths.src.images %>"
          src: ["**/*.{png,jpg,gif}"]
          dest: "<%= paths.dist.images %>"
        ]

    copy:
      images:
        expand: true
        cwd: "<%= paths.src.images %>"
        src: ["**/*.{png,jpg,gif}"]
        dest: "<%= paths.dist.images %>"

      html:
        expand: true
        flatten: true
        src: "<%= paths.src.root %>/**/*.html"
        dest: "<%= paths.dist.root %>/"

    processhtml:
      options:
        process: true

      dev:
        expand: true
        cwd: "<%= paths.dist.root %>"
        src: ["**/*.html"]
        dest: "<%= paths.dist.root %>"

      production:
        expand: true
        cwd: "<%= paths.dist.root %>"
        src: ["**/*.html"]
        dest: "<%= paths.dist.root %>"

    handlebars:
      compile:
        options:
          namespace: "App.templates"
          processName: (path) ->
            path = path.replace grunt.config("paths.src.app")+"/", ""
            path = path.replace ".hbs", ""
            return path
        files:
          "<%= paths.src.app %>/templates/templates.js" : "<%= paths.src.app %>/**/*.hbs"

    concat:
      compile:
        src: ["<%= paths.dist.root %>/app.js", "<%= paths.src.app %>/templates/templates.js"]
        dest: "<%= paths.dist.root %>/app.js",

    autoprefixer:
      options:
        browsers: ["last 1 version", "> 1%", "ie 8", "ie 7"]

      compile:
        src: "<%= paths.dist.root %>/styles.css"
        dest: "<%= paths.dist.root %>/styles.css"

    cssmin:
      compile:
        files:
          "<%= paths.dist.root %>/styles.min.css": "<%= paths.dist.root %>/styles.css"

    sass:
      compile:
        options:
          imagePath: "images"
          outputStyle: "compressed"
          sourceMap: true
        files:
          "<%= paths.dist.root %>/styles.css": "<%= paths.src.root %>/styles.scss"

    connect:
      server:
        options:
          port: 3000
          livereload: true

    casperjs:
      files: ["<%= paths.tests.functional %>/**/*.coffee"]

    mocha:
      test:
        options:
          run: true
          urls: ["http://localhost:3000/test/unit/"]

    groc:
      javascript: ["src/app/**/*.coffee", "README.markdown"]
      options:
        out: "<%= paths.docs %>/"

    watch:
      app:
        files: ["<%= paths.src.root %>/**/*.coffee", "<%= paths.src.root %>/**/*.hbs"]
        tasks: ["app:dev"]
        options:
          livereload: true
      styles:
        files: ["<%= paths.src.root %>/styles.scss", "<%= paths.src.styles %>/**/*.scss"]
        tasks: ["styles:dev"]
        options:
          livereload: true
      html:
        files: ["<%= paths.src.root %>/index.html"]
        tasks: ["html:dev"]
        options:
          livereload: true
      images:
        files: ["<%= paths.src.images %>/**/*"]
        tasks: ["images"]
        options:
          livereload: true
      functional_tests:
        files: ["<%= paths.tests.functional %>/**/*.coffee"]
        tasks: ["casperjs"]
      unit_tests:
        files: ["<%= paths.tests.unit %>/specs/**/*.coffee"]
        tasks: ["app:dev", "app:test", "mocha"]
        options:
          livereload: true

  grunt.registerTask "images", ["clean:images", "copy:images"]
  grunt.registerTask "html", ["copy:html", "processhtml:production"]
  grunt.registerTask "html:dev", ["copy:html", "processhtml:dev"]
  grunt.registerTask "app:dev", ["mince:app", "templates"]
  grunt.registerTask "app:test", ["mince:test"]
  grunt.registerTask "app:production", ["mince:app", "templates", "uglify:production" ]
  grunt.registerTask "styles:dev", ["sass", "autoprefixer"]
  grunt.registerTask "styles:production", ["styles:dev", "cssmin"]
  grunt.registerTask "templates", ["handlebars", "concat"]

  grunt.registerTask "dev", ["clean:dist", "app:dev", "app:test", "html:dev", "images", "styles:dev"]
  grunt.registerTask "production", ["connect", "clean:dist", "clean:docs", "app:production", "html", "imagemin", "styles:production", "casperjs", "mocha", "groc"]
  grunt.registerTask "default", ["dev", "connect", "watch"]

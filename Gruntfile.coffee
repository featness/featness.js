# Generated on 2014-05-13 using generator-bower 0.0.1
'use strict'

mountFolder = (connect, dir) ->
    connect.static require('path').resolve(dir)

module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  yeomanConfig =
    src: 'src'
    dist : 'dist'
    bower: 'bower_components'
  grunt.initConfig
    yeoman: yeomanConfig

    coffee:
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.src %>'
          src: '{,*/}*.coffee'
          dest: '<%= yeoman.dist %>'
          ext: '.js'
        ]
    concat:
      options:
        separator: ';'
      dist:
        src: ['<%=yeoman.bower %>/asynqueue/queue.js', '<%=yeoman.dist %>/featness.js']
        dest: '<%=yeoman.dist %>/featness.js'
    uglify:
      build:
        src: '<%=yeoman.dist %>/featness.js'
        dest: '<%=yeoman.dist %>/featness.min.js'
    mochaTest:
      test:
        options:
          reporter: 'spec'
          compilers: 'coffee:coffee-script'
        src: ['test/**/*.coffee']

    grunt.registerTask 'default', [
      'mochaTest'
      'coffee'
      'concat'
      'uglify'
    ]

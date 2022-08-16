pipelineJob('build-number-guesser') {
  definition {
    cpsScm {
      scm {
        git {
          remote {
            url('https://github.com/tanishka-amin/number-guesser.git')
            credentials('git-access-token')
          }
          branch('*/feature/2.1')
        }
      }
      lightweight()
    }
  }
}
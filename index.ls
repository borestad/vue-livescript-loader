require! {
  'livescript': LS
  'loader-utils': Utils
}

module.exports = (source) ->
  @cacheable?!
  const ls-request = Utils.get-remaining-request(this)
  const js-request = Utils.get-current-request(this)
  const query = Utils.parse-query(@query)
  result = void

  # Support .vue files by replacing '//' with '#'
  # https://github.com/vuejs/vue-loader/issues/135
  source = source.replace //^[\/]{2}//g, '#'

  config =
    filename: ls-request
    output-filename: js-request
    map: 'linked'
    bare: true
    const: false
    header: false

  # Merge query and config
  config <<< query

  try
    result = LS.compile(source, config)
  catch e
    err = ''
    unless (e.location?.first_column? or e.location?.first_line?)
      err += "Got an unexpected exception from the livescript compiler. The original exception was: #{e}"
    else
      const line = source.split('\n')[e.location.first_line]
      const {first_column, first_line} = e.location
      const offending-character = if first_column < codeLine.length then codeLine[first_column] else ''

      err += """
        #{e}
        L: #{first_line}: #{codeLine.substring(0)} #{first_column} #{offending-character} #{codeLine.substring e.location.first_column + 1}
        #{new Array first_column + 1}
      """

    throw new Error(err)

  map = JSON.parse(result.map)
  @callback(null, result.code, map)

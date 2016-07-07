Promise = require 'bluebird'
async = Promise.coroutine
request = Promise.promisifyAll require('request')
{relative, join} = require 'path-extra'
path = require 'path-extra'
fs = require 'fs-extra'
{_, $, $$, React, ReactBootstrap, ROOT, resolveTime, layout, toggleModal} = window
{Table, Grid, Col, Row, Alert, Button, Input} = ReactBootstrap
Divider = require './views/divider'

webview = $('kan-game webview')

__ = window.i18n['poi-plugin-old-driver'].__.bind(window.i18n['poi-plugin-old-driver'])

module.exports =
  reactClass: React.createClass
    getInitialState: ->
      areaNodeInfo: config.get 'plugin.OldDriver.areaNodeInfo',[]
      refreshPage: config.get 'plugin.OldDriver.refreshPage',false
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      switch path
        when '/kcsapi/api_req_map/start','/kcsapi/api_req_map/next'
          nodeInfo=[body.api_maparea_id,body.api_mapinfo_no,body.api_no]
          @checkNodeInfo nodeInfo.join '-'
    handleChangeSettings: (e) ->
      state = !@state.refreshPage
      @setState
        refreshPage: state
      config.set 'plugin.OldDriver.refreshPage', state
    handleChangeNode: (index) ->
      info = @state.areaNodeInfo
      info[index].nodeNumber = @refs["nodeNumber#{index}"].getValue()
      @setState
        areaNodeInfo: info
      config.set 'plugin.OldDriver.areaNodeInfo', info
    handleAddNode: ->
        info = @state.areaNodeInfo
        info.push {nodeNumber: ''}
        @setState
          areaNodeInfo: info
        config.set 'plugin.OldDriver.areaNodeInfo', info
    handleDeleteNode: (index) ->
        info = @state.areaNodeInfo
        info.splice index, 1
        @setState
          areaNodeInfo: info
        config.set 'plugin.OldDriver.areaNodeInfo', info
    checkNodeInfo: (nodeNumber) ->
      for node in @state.areaNodeInfo when nodeNumber == node.nodeNumber
        setTimeout  =>
          window.notify(__ 'About to enter area %s',  mapInfo)
          if @state.refreshPage
            webview.reload()
        ,1000
    render: ->
      <div id='old-driver' className='old-driver'>
            <Grid>
                <Row>
                  <Col xs={12}>
                    <Divider text={__ 'Settings'} />
                    <Input type='checkbox' label={__ 'Refresh page'} value={@state.refreshPage} onChange={@handleChangeSettings} checked={@state.refreshPage} />
                    <Divider text={__ 'Node list'} />
                    <Table striped bordered condensed hover>
                      <thead>
                        <tr>
                          <th style={verticalAlign: 'middle'}>
                            <FontAwesome name='plus-circle' onClick={@handleAddNode}/>
                          </th>
                          <th>
                            {__ 'Node number'}
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {
                          for node, index in @state.areaNodeInfo
                              <tr key={index}>
                                <td style={verticalAlign: 'middle'}>
                                  <FontAwesome name='minus-circle' onClick={@handleDeleteNode.bind @, index}/>
                                </td>
                                <td>
                                  <Input type="text" ref="nodeNumber#{index}"
                                  placeholder={__ 'Enter the map node here (e.g. 5-1-2, 3-5-1)'}
                                  value={@state.areaNodeInfo[index].nodeNumber}
                                  onChange={@handleChangeNode.bind @, index} />
                                </td>
                              </tr>
                        }
                      </tbody>
                    </Table>
                  </Col>
                </Row>
            </Grid>
      </div>
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse

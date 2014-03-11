class pipes.views.PipeItemView extends Backbone.View
  template: templates['pipe-item.html']
  className: 'row pipe'

  stepper: null

  events:
    'click .button.sync': 'startSync'

  initialize: ->
    console.log('initialize', @model, @)
    @listenTo @model, 'change:status change:message', @refreshStatus
    @cogView = new pipes.views.CogView
      el: @$('.cog-box')
      items: [
        {name: 'getup1', label: "Get up!", fn: ->}
        {name: 'getup2', label: "Get on uppah!", fn: ->}
        {name: 'getup3', label: "Get up!", fn: ->}
        {name: 'getup4', label: "Get on uppah!", fn: ->}
        pipes.views.CogView.divider
        {name: 'getdown', label: "Get down!", fn: ->}
      ]
    @metaView = new pipes.views.PipeItemMetaView
      el: @$('.meta')
      model: @model
    @stepper = pipes.getStepper(@model.collection.integration, @model, @)
    @stepper.on 'step', @stepChanged

  stepChanged: (step, i, steps) =>
    @refreshSyncButton()

  startSync: =>
    @model.status 'in_progress'
    @model.statusMessage 'In progress'
    @stepper.endCurrentStep() if @stepper.current.default

  render: =>
    @$el.html @template model: @model
    @cogView.setElement @$('.cog-box')
    @cogView.render()
    @metaView.setElement @$('.meta')
    @metaView.render()
    @$el.foundation()
    @refreshSyncButton()
    @

  refreshSyncButton: ->
    # Allow sync button only in default step if status = ok
    @$('.button.sync')
      .attr 'disabled', not @stepper.current.default or @model.status() != 'success'
      .children('.button-label').text if @stepper.current.default and @model.status() == 'success' then "Sync now" else "Syncing..."

  refreshStatus: ->
    @metaView.render()
    @refreshSyncButton()


class pipes.views.PipeItemMetaView extends Backbone.View
  template: templates['pipe-item-meta.html']

  render: =>
    @$el.html @template model: @model
    @


pipes.getStepper  = (integration, pipe, pipeView) ->
  console.log('pipes.getStepper', 'integration:', integration, 'pipe:', pipe, 'pipeView:', pipeView)
  switch integration.id
    when 'basecamp'
      switch pipe.id
        when 'users'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(
                default: true
                url: pipe.url()
              )
              new pipes.steps.OAuthStep(
                integration: integration
                pipe: pipe
              )
              new pipes.steps.AccountSelectorStep(
                url: integration.accountsUrl()
                outKey: 'accountId'
              )
              new pipes.steps.DataPollStep(
                url: "#{pipe.url()}/users"
                requestMap: {'account_id': 'accountId'} # Mapping 'query string param name': 'key in sharedData'
                responseMap: {'users': 'users'} # Mapping 'key in sharedData': 'key in response data'
              )
              new pipes.steps.ManualPickerStep(
                inKey: 'users'
                outKey: 'selectedUsers'
                columns: [{key: 'name', label: "Name"}, {key: 'email', label: "E-mail"}]
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/users"
                requestMap: {ids: 'selectedUsers'} # Mapping 'query string param name': 'key in sharedData'
              )
            ]
        else
          throw "Integration #{integration.id} doesn't have logic for pipe #{pipe.id}"
    else
      throw "Integration #{integration.id} doesn't have any pipes defined"


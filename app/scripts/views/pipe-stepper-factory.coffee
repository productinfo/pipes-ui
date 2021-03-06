pipes.pipeStepperFactory = (integration, pipe, pipeView) ->
  switch integration.id
    when 'basecamp', 'teamweek', 'asana', 'github'
      switch pipe.id
        when 'users'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(default: true)
              new pipes.steps.AccountSelectorStep(
                skip: -> pipe.get 'configured'
              )
              new pipes.steps.DataSubmitStep(
                skip: -> pipe.get 'configured'
                url: "#{pipe.url()}/setup"
                requestMap: {'account_id': 'account_id'}
                successCallback: (response, step) ->
                  pipe.set
                    configured: true
                    account_id: step.sharedData.account_id
              )
              new pipes.steps.DataPollStep(
                url: "#{pipe.url()}/users"
                responseMap: {'users': 'users'} # Mapping 'key in sharedData': 'key in response data'
              )
              new pipes.steps.ManualPickerStep(
                title: "Select users to import"
                inKey: 'users'
                outKey: 'selectedUsers'
                columns: [{key: 'name', label: "Name", filter: true}, {key: 'email', label: "E-mail", filter: true}]
                customOptions: [{key: 'sendInvites', checked: true, label: "Email invitations to these users.<br /> <span class='disclaimer'>(NB! Your monthly fee may change)</span>"}]
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/run"
                requestMap: {'ids': 'selectedUsers', 'send_invites': 'sendInvites'} # Mapping 'query string param name': 'key in sharedData'
              )
            ]
        when 'projects'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(default: true)
              new pipes.steps.AccountSelectorStep(
                skip: -> pipe.get 'configured'
              )
              new pipes.steps.DataSubmitStep(
                skip: -> pipe.get 'configured'
                url: "#{pipe.url()}/setup"
                requestMap: {'account_id': 'account_id'}
                successCallback: (response, step) ->
                  pipe.set
                    configured: true
                    account_id: step.sharedData.account_id
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/run"
              )
            ]
        when 'todolists', 'todos', 'tasks'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(default: true)
              new pipes.steps.AccountSelectorStep(
                skip: -> pipe.get 'configured'
              )
              new pipes.steps.DataSubmitStep(
                skip: -> pipe.get 'configured'
                url: "#{pipe.url()}/setup"
                requestMap: {'account_id': 'account_id'}
                successCallback: (response, step) ->
                  pipe.set
                    configured: true
                    account_id: step.sharedData.account_id
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/run"
              )
            ]
        else
          throw "Integration #{integration.id} doesn't have logic for pipe #{pipe.id}"
    when 'freshbooks'
      switch pipe.id
        when 'users'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(default: true)
              new pipes.steps.DataSubmitStep(
                skip: -> pipe.get 'configured'
                url: "#{pipe.url()}/setup"
                requestMap: {'account_name': 'account_name'}
                successCallback: (response, step) ->
                  pipe.set
                    configured: true
                    account_name: step.sharedData.account_name
              )
              new pipes.steps.DataPollStep(
                url: "#{pipe.url()}/users"
                responseMap: {'users': 'users'} # Mapping 'key in sharedData': 'key in response data'
              )
              new pipes.steps.ManualPickerStep(
                title: "Select users to import"
                inKey: 'users'
                outKey: 'selectedUsers'
                columns: [{key: 'name', label: "Name", filter: true}, {key: 'email', label: "E-mail", filter: true}]
                customOptions: [{key: 'sendInvites', checked: true, label: "Email invitations to these users.<br /> <span class='disclaimer'>(NB! Your monthly fee may change)</span>"}]
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/run"
                requestMap: {'ids': 'selectedUsers', 'send_invites': 'sendInvites'} # Mapping 'query string param name': 'key in sharedData'
              )
            ]
        when 'projects', 'tasks'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(default: true)
              new pipes.steps.DataSubmitStep(
                skip: -> pipe.get 'configured'
                url: "#{pipe.url()}/setup"
                requestMap: {'account_name': 'account_name'}
                successCallback: (response, step) ->
                  pipe.set
                    configured: true
                    account_name: step.sharedData.account_name
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/run"
              )
            ]
        when 'timeentries'
          return new pipes.steps.Stepper
            view: pipeView
            steps: [
              new pipes.steps.IdleState(default: true)
              new pipes.steps.DatePickerStep(
                title: "Export time entries starting from:"
                outKey: 'start_date'
                skip: -> pipe.get 'configured'
              )
              new pipes.steps.DataSubmitStep(
                skip: -> pipe.get 'configured'
                url: "#{pipe.url()}/setup"
                requestMap: {'account_name': 'account_name', 'start_date': 'start_date'}
                successCallback: (response, step) ->
                  pipe.set
                    configured: true
                    account_name: step.sharedData.account_name
              )
              new pipes.steps.DataSubmitStep(
                url: "#{pipe.url()}/run"
              )
            ]
        else
          throw "Integration #{integration.id} doesn't have logic for pipe #{pipe.id}"
    else
      throw "Integration #{integration.id} doesn't have any pipes defined"


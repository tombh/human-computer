module Routes
  # /process
  class Process < Grape::API
    resource :process do
      desc 'Return information about a process'
      params do
        requires :pid, type: Integer, desc: 'Process ID'
      end
      route_param :pid do
        get do
          HumanComputer::Process.find params[:pid]
        end
        get 'memory/:address' do
          HumanComputer::Memory.find_by(
            process: params[:pid],
            address: params[:address]
          ).tiles.map { |t| t.paths = JSON.parse(t.paths); t}
        end
      end
    end
  end
end

module Routes
  # /process
  class Process < Grape::API
    resource :process do
      desc 'Return information about a process'
      params do
        requires :pid, type: Integer, desc: 'Process ID'
      end
      route_param :pid do
        desc 'Returns details about the process'
        get do
          pid = Pid.find params[:pid]
          present pid, with: PidRepresenter
        end

        desc 'Returns a set of memory tiles, that fit into a quadtree map tile'
        params do
          requires(
            :addresses,
            type: Array,
            desc: "Array of decimal addresses, or 'all' for all addresses"
          )
          optional :uncompressed, type: Boolean, desc: 'Return tile data uncompressed'
        end
        get 'memory' do
          pid = Pid.find params[:pid]
          addresses = params[:addresses]
          if addresses.first.downcase == 'all'
            bytes = Address.where pid: pid
          else
            addresses.map! { |a| HumanComputer::Processor.eight_bitify a.to_i }
            bytes = Address.where(pid: pid).in(address: addresses)
          end
          raw = AddressRepresenter.prepare(bytes)
          if params[:uncompressed]
            raw
          else
            json = raw.to_json
            zlib_without_headers = Zlib::Deflate.new(nil, -Zlib::MAX_WBITS)
            compressed = zlib_without_headers.deflate(json, Zlib::FINISH)
            {
              decompressedSize: json.size,
              base64EncodedCompressedJSON: Base64.encode64(compressed)
            }
          end
        end
      end
    end
  end
end

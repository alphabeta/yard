class YARD::Handlers::Ruby::MethodHandler < YARD::Handlers::Ruby::Base
  handles :def, :defs
  
  def process
    nobj = namespace
    mscope = scope
    if statement.type == :defs
      meth = statement[2][0]
      nobj = P(namespace, statement[0].source) unless statement[0].source == "self"
      args = format_args(statement[3])
      blk = statement[4]
      mscope = :class
    else
      meth = statement[0][0]
      args = format_args(statement[1])
      blk = statement[2]
    end
    
    obj = register MethodObject.new(nobj, meth, mscope) do |o| 
      o.visibility = visibility 
      o.source = statement.source
      o.signature = method_signature(meth)
      o.explicit = true
      o.parameters = args
    end
    
    parse_block(blk, :owner => obj) # mainly for yield/exceptions
  end
  
  def format_args(args)
    args = args.jump(:params)
    params = []
    params += args.required_params.map {|a| [a.source, nil] } if args.required_params
    params += args.optional_params.map {|a| [a[0].source, a[1].source] } if args.optional_params
    params << ["*" + args.splat_param.source, nil] if args.splat_param
    params += args.required_end_params.map {|a| [a.source, nil] } if args.required_end_params
    params << ["&" + args.block_param.source, nil] if args.block_param
    params
  end
  
  def method_signature(method_name)
    if statement[1]
      "def #{method_name}(#{statement[1].jump(:params).source})"
    else
      "def #{method_name}"
    end
  end
end
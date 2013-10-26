-module(mprd_master).                                                           
-compile(export_all).                                                           
                                                                                
map(Func, UserReduce, List, SlaveNum) ->                                        
    Pid = self(),                                                               
    Pids = lists:map(fun(I) -> spawn(fun() -> do_work(Pid, Func, I) end) end, List),
    case SlaveNum > 0 of                                                        
        true -> Res = gather(Pids, SlaveNum);                                   
        _ -> Res = Pids                                                         
    end,                                                                        
    R = reduce(Res),                                                            
    UserReduce(R).                                                              
    %io:format("~w~n", [R]).                                                    
    %lists:foreach(fun(X) -> print(X) end, R).                                  
                                                                                
reduce([]) ->                                                                   
    [];                                                                         
                                                                                
reduce([H | T]) ->                                                              
    receive                                                                     
        {H, Res} ->                                                             
            [Res | reduce(T)]                                                   
    end.                                                                        
                                                                                
gather(Pids, 0) ->                                                              
    Pids;                                                                       
                                                                                   
gather(Pids, SlaveNum) ->                                                          
    receive                                                                        
        {finished, SlaveRes} ->                                                    
            Res = lists:append(Pids, SlaveRes),                                    
            gather(Res, SlaveNum - 1)                                              
    end.                                                                           
                                                                                   
print(Ele) ->                                                                      
    io:format("~w~n", [Ele]).                                                      
                                                                                   
do_work(Parent, Func, I) ->                                                        
    Parent ! {self(), (catch Func(I))}.                                            
                                                                                   
my_spawn({SlaveNode, L}, Func) ->                                                  
    spawn(SlaveNode, mprd_slave, map, [Func, L, master, node()]).                  
                                                                                   
my_split([], _, _, L) ->                                                           
    L;                                         
    my_split(List, Len, NodeCnt, L) when length(List) >= Len ->                        
    case length(L) of                                                              
        NodeCnt  ->                                                                
            [List | L];                                                            
        _ ->                                                                    
            {H, T} = lists:split(Len, List),                                    
            my_split(T, Len, NodeCnt, [H | L])                                  
    end;                                                                        
                                                                                
my_split(List, Len, _, L) ->                                                    
    L.                                                                          
                                                                                
start(Func,UserReduce, L) ->                                                    
    register(master, spawn(mprd_master, map, [Func, L, 0])).                    
                                                                                
start(SlaveNodes, Func, UserReduce, L) when length(SlaveNodes) > length(L) -1 ->
    io:format("Make sure the number of slave node is less than the length of List please!\n");
                                                                                
start(SlaveNodes, Func, UserReduce, L) ->                                       
    % slave + master                                                            
    Nodes = length(SlaveNodes) + 1,                                             
    Len = length(L) div Nodes,                                                  
    [H | Lists] = my_split(L, Len, length(SlaveNodes), []),                     
    io:format("Master: ~w~n", [H]),                                             
    XS = lists:zip(SlaveNodes, Lists),                                          
    io:format("~p~n", [XS]),                                                    
    register(master, spawn(mprd_master, map, [Func, UserReduce, H, length(SlaveNodes)])),
    [my_spawn(X, Func) || X <- XS],                                             
    ok.

-module(mprd_slave).                                                               
-compile(export_all).                                                              
                                                                                   
map(Func, List, MasterName, MasterNode) ->                                         
    Pids = lists:map(fun(I) -> spawn(fun() -> do_work(MasterName, MasterNode, Func, I) end) end, List),
    {MasterName, MasterNode} ! {finished, Pids}.                                   
                                                                                   
do_work(MasterName, MasterNode, Func, I) ->                                        
    {MasterName, MasterNode} ! {self(), (catch Func(I))}.                          


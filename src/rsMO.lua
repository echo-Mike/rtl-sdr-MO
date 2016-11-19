
--http://patorjk.com/software/taag/#p=display&c=lua&f=Banner3&t=lua

local function log_and_tmp_setup()
    --Initiate Lua RNG with os.time
    math.randomseed(os.time())
    --Create selector for current session 
    local tmp_file_selector = string.format("%u",math.random(100000))
    --Setup short file names
    tmp_file_name = "auto_mes_tmp_"..tmp_file_selector
    log_file_name = "auto_mes_log_"..tmp_file_selector
    --pwd analog : save current directory to file log_file_name
    os.execute("echo %cd% > "..log_file_name)
    --Read and format current directory string
    log_file = io.open(log_file_name)
    local buff = log_file:read("*l")
    buff = buff:sub(1,#buff-1)
    buff = buff.."\\"
    --Create full paths to current log and tmp files 
    tmp_file_name = buff..tmp_file_name
    log_file_name = buff..log_file_name
    --Close buff file
    log_file:close()
    --Open and create log and tmp file
    log_file = io.open(log_file_name,"w+")
    tmp_file = io.open(tmp_file_name,"w+")
end

log_and_tmp_setup()

--[[
########     ###    ########    ###    
##     ##   ## ##      ##      ## ##   
##     ##  ##   ##     ##     ##   ##  
##     ## ##     ##    ##    ##     ## 
##     ## #########    ##    ######### 
##     ## ##     ##    ##    ##     ## 
########  ##     ##    ##    ##     ## 
]]

local frequency_data = {
    min = 26*10^6,
    max = 1760*10^6,
    central_frequency = 100*10^6,
    span = 10*10^7,
    begin_frequency = central_frequency - span / 2,
    end_frequency = central_frequency + span / 2,
}

local device_data = {
    multimple = false,
    device_index = {0},
    gain = {0},
    ppm = {0}
}

local rtl_power_data = {
    begin_frequency = frequency_data.begin_frequency,
    end_frequency = frequency_data.end_frequency,
    rbw = 10^5,
    crop = 25,
    window = {
        "-w hamming ",
        "-w blackman ",
        "-w blackman-harris ",
        "-w hann-poisson ",
        "-w bartlett ",
        "-w youssef "
    },
    window_selector = 1,
    integration_interval = 1,
    single_shot = true
}

local rtl_sdr_data = {
    central_frequency = frequency_data.central_frequency,
    span = frequency_data.span,
    samples_to_read = 10 * frequency_data.span 
}

local file_data = {
    general_name = "",
    measurement_number = 0,
    measurement_prefix = "mes",
    device_prefix = "dev",
    frequency_prefix = "f",
    crop_prefix = "c",
    window_prefix = "w"
}

--[[
##     ## ######## ##    ## ##     ##    ########     ###    ########    ###    
###   ### ##       ###   ## ##     ##    ##     ##   ## ##      ##      ## ##   
#### #### ##       ####  ## ##     ##    ##     ##  ##   ##     ##     ##   ##  
## ### ## ######   ## ## ## ##     ##    ##     ## ##     ##    ##    ##     ## 
##     ## ##       ##  #### ##     ##    ##     ## #########    ##    ######### 
##     ## ##       ##   ### ##     ##    ##     ## ##     ##    ##    ##     ## 
##     ## ######## ##    ##  #######     ########  ##     ##    ##    ##     ## 
]]

local main_menu = {
    "Main menu:"
    "/tf:File data setup",
    "/ts:Enter rtl_sdr menu",
    "/tp:Enter rtl_power menu",
    "/tb:Back to previous menu",
    "/te:Exit"
}

local rtl_power_menu = {
    "rtl_power menu:",
    "/tf:Setup frequency range",
    "/tr:Setup RBW",
    "/ti:Set integration interval",
    "/t1:Single-shot mode",
    "/td:Choose device",
    "/tg:Setup gain",
    "/tp:Setup ppm",
    "/tw:Setup window",
    "/tc:Setup crop percent",
    "/th:Peak hold mode",
    "/n",
    "/tm:Back to Main menu",
    "/tb:Back to previous menu",
    "/te:Exit"
}

local rtl_sdr_menu = {
    "rtl_sdr menu:",
    "/tf:Setup central frequency",
    "/ts:Setup span",
    "/td:Choose device",
    "/tg:Setup gain",
    "/tp:Setup ppm",
    "/tn:Setup samples to read",
    "/ENTER:Start recording",
    "/n",
    "/tm:Back to Main menu",
    "/tb:Back to previous menu",
    "/te:Exit"
}

local file_menu = {
    "File menu:",
    "/tg:Setup general name",
    "/tp:Setup prefixes",
    "/tb:Back to previous menu",
    "/tm:Back to Main menu",
    "/te:Exit"
}

local prefix_menu = {
    "Prefix menu:",
    "/tm:Edit measurement prefix",
    "/td:Edit device prefix",
    "/tf:Edit frequency prfix",
    "/tc:Edit crop prefix"
    "/tb:Back to previous menu",
    "/te:Exit"
}

--[[
##     ## ######## ##    ## ##     ##                              
###   ### ##       ###   ## ##     ##                              
#### #### ##       ####  ## ##     ##                              
## ### ## ######   ## ## ## ##     ##                              
##     ## ##       ##  #### ##     ##                              
##     ## ##       ##   ### ##     ##                              
##     ## ######## ##    ##  #######   

##     ##    ###    ##    ## ########  ##       ######## ########  
##     ##   ## ##   ###   ## ##     ## ##       ##       ##     ## 
##     ##  ##   ##  ####  ## ##     ## ##       ##       ##     ## 
######### ##     ## ## ## ## ##     ## ##       ######   ########  
##     ## ######### ##  #### ##     ## ##       ##       ##   ##   
##     ## ##     ## ##   ### ##     ## ##       ##       ##    ##  
##     ## ##     ## ##    ## ########  ######## ######## ##     ## 
--]]

local menu_handler = {
    menu_selector = 1,
    previous_menu = {1},
    
}

--[[
##    ## ######## ##    ## ########   #######     ###    ########  ########  
##   ##  ##        ##  ##  ##     ## ##     ##   ## ##   ##     ## ##     ## 
##  ##   ##         ####   ##     ## ##     ##  ##   ##  ##     ## ##     ## 
#####    ######      ##    ########  ##     ## ##     ## ########  ##     ## 
##  ##   ##          ##    ##     ## ##     ## ######### ##   ##   ##     ## 
##   ##  ##          ##    ##     ## ##     ## ##     ## ##    ##  ##     ## 
##    ## ########    ##    ########   #######  ##     ## ##     ## ########  

##     ##    ###    ##    ## ########  ##       ######## ########            
##     ##   ## ##   ###   ## ##     ## ##       ##       ##     ##           
##     ##  ##   ##  ####  ## ##     ## ##       ##       ##     ##           
######### ##     ## ## ## ## ##     ## ##       ######   ########            
##     ## ######### ##  #### ##     ## ##       ##       ##   ##             
##     ## ##     ## ##   ### ##     ## ##       ##       ##    ##            
##     ## ##     ## ##    ## ########  ######## ######## ##     ##           
--]]

local kyeboard_handler = {

}

--[[
######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######  
##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ## 
##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##       
######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######  
##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ## 
##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ## 
##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######  
]]

function sync_span()
    if frequency_data.end_frequency >= frequency_data.begin_frequency then
        frequency_data.span = math.floor(frequency_data.end_frequency - frequency_data.begin_frequency)
    else
        print("Auto_Mesur: End frequency are less then begin frequency")
    end
end

function sync_be()
    if frequency_data.span > 250000 then
        frequency_data.begin_frequency = math.floor(frequency_data.central_frequency - frequency_data.span/2)
        if frequency_data.begin_frequency < frequency_data.min then 
            frequency_data.begin_frequency = frequency_data.min
        end
        frequency_data.end_frequency = math.floor(frequency_data.central_frequency + frequency_data.span/2)
        if frequency_data.end_frequency > frequency_data.max then 
            frequency_data.end_frequency = frequency_data.max
        end
    else
        print("Auto_Mesur: Span must be grater then 250 000 Hz")
    end
end

function construct_sdr_filename()
    
end

function construct_power_filename()
    
end

function rtl_sdr()
    local s = "rtl_sdr -f "
    s = s..string.format("%u", frequency_data.central_frequency)
    s = s.." -s "..string.format("%u", frequency_data.span)
end

function rtl_power()
    
end

function cls() os.execute("cls") end

function print_current_menu() menu_handler.print() end

function analyze_input() kyeboard_handler.key() end

--[[
##     ##    ###    #### ##    ##     ######  ##    ##  ######  ##       ######## 
###   ###   ## ##    ##  ###   ##    ##    ##  ##  ##  ##    ## ##       ##       
#### ####  ##   ##   ##  ####  ##    ##         ####   ##       ##       ##       
## ### ## ##     ##  ##  ## ## ##    ##          ##    ##       ##       ######   
##     ## #########  ##  ##  ####    ##          ##    ##       ##       ##       
##     ## ##     ##  ##  ##   ###    ##    ##    ##    ##    ## ##       ##       
##     ## ##     ## #### ##    ##     ######     ##     ######  ######## ######## 
]]

while true do
    print_current_menu()
    analyze_input()
end
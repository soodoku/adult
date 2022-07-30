import time

DOMAIN_LIST_FILE = "porn_domains_list.txt" #"website_list_gentzkow_shapiro.txt"#
INTERNET_USAGE_FILE = "../../web_browsing_2004" #"8bdff911e30b975c.csv"#
FINAL_OUTPUT_FILE = "final_output_each_machineid_date_domain.csv"

FINAL_OUTPUT_HEADER = "machine_id, date, total_pages_viewed, total_time_spent, total_pages_viewed_porn_domains, total_time_spent_porn_domains"
USE_DOMAIN_LIST_FILE = True

#############################READ DOMAIN LIST FILE#######################################
DOMAIN_LIST = []
if USE_DOMAIN_LIST_FILE and len(DOMAIN_LIST_FILE)>0:
    print "Read the domain list file %s" %(DOMAIN_LIST_FILE,)
    with open(DOMAIN_LIST_FILE) as myfile:
        for line in myfile:
            DOMAIN_LIST.append(line.strip().replace("\n",""))
    print "Lengnth domain list  = %s\n" %(len(DOMAIN_LIST),)
        
# Add additional column into FINAL_OUTPUT_HEADER 
for i in range(len(DOMAIN_LIST)):
    FINAL_OUTPUT_HEADER = FINAL_OUTPUT_HEADER + ", domain_%s_pages_viewed, domain_%s_time_spent"%(i+1,i+1,)

my_output_file = open(FINAL_OUTPUT_FILE,"w")
my_output_file.write(FINAL_OUTPUT_HEADER + "\n")

###############################START PROCESSING DATA#####################################
print "Start processing the data file %s" %(INTERNET_USAGE_FILE,)
    
fist_line = True
prev_machine_id = -1
DATA_BY_DATE = {}
count = 0
prev_timer = time.time()
usage_each_date_domain={}
with open(INTERNET_USAGE_FILE) as myfile:
    for line in myfile:
        # Monitor the progress
        count = count + 1
        if (count%100000==0):
            now = time.time()
            difference = int(now - prev_timer)
            print "   + Processing line %s00.000th time_till_now=%s(s)"%(count/100000,difference,)
            
        if fist_line: # Skip the first row
            fist_line = False
        else:
            # Extract data in a row
            datas = line.split(",")
            domain = datas[1]
            if len(datas)==9:
                machine_id = datas[3]
                pages_viewed = int(float(datas[6]))
                duration = int(float(datas[5]))
                date =  datas[7]
            elif len(datas)==8:
                machine_id = datas[2]
                pages_viewed = int(float(datas[5]))
                duration = int(float(datas[4]))
                date =  datas[6]
                
            porn_domain_counted = not USE_DOMAIN_LIST_FILE or domain in DOMAIN_LIST
            if machine_id!=prev_machine_id:
                    # Print the data for prev_machine_id
                    for d in DATA_BY_DATE.keys():
                        rowStr = "%s,%s,%s,%s,%s,%s" % (prev_machine_id, d, DATA_BY_DATE[d][0], DATA_BY_DATE[d][1],DATA_BY_DATE[d][2], DATA_BY_DATE[d][3],)
                        usage_each_date_domain = DATA_BY_DATE[d][4]
                        for d in DOMAIN_LIST:
                            if d in usage_each_date_domain.keys():
                                rowStr = rowStr + ",%s,%s"%(usage_each_date_domain[d][0],usage_each_date_domain[d][1],)
                            else:
                                rowStr = rowStr + ",,"
                        rowStr = rowStr + "\n"
                        my_output_file.write(rowStr)
                    
                    # Reset the log
                    DATA_BY_DATE = {}
                    usage_each_date_domain={domain:[pages_viewed, duration]}
                    if porn_domain_counted:
                        DATA_BY_DATE[date] = [pages_viewed, duration,pages_viewed, duration,usage_each_date_domain]
                    else:
                        DATA_BY_DATE[date] = [pages_viewed, duration,0,0,usage_each_date_domain]
                    prev_machine_id = machine_id
            else:  
                    if date in DATA_BY_DATE.keys():
                        usage_each_date_domain = DATA_BY_DATE[date][4]
                        if domain in usage_each_date_domain.keys():
                            usage_each_date_domain[domain] = [usage_each_date_domain[domain][0] + pages_viewed,usage_each_date_domain[domain][1] + duration]
                        else:
                            usage_each_date_domain[domain] = [pages_viewed, duration]
                            
                        if porn_domain_counted:
                            DATA_BY_DATE[date] = [DATA_BY_DATE[date][0] + pages_viewed, DATA_BY_DATE[date][1] + duration, DATA_BY_DATE[date][2] + pages_viewed, DATA_BY_DATE[date][3] + duration, usage_each_date_domain]
                        else:
                            DATA_BY_DATE[date] = [DATA_BY_DATE[date][0] + pages_viewed, DATA_BY_DATE[date][1] + duration, DATA_BY_DATE[date][2], DATA_BY_DATE[date][3], usage_each_date_domain]
                            
                    else:
                        usage_each_date_domain={domain:[pages_viewed, duration]}
                        if porn_domain_counted:
                            DATA_BY_DATE[date] = [pages_viewed, duration,pages_viewed, duration,usage_each_date_domain]
                        else:
                            DATA_BY_DATE[date] = [pages_viewed, duration,0,0,usage_each_date_domain]
    # Print the data for prev_machine_id
    for d in DATA_BY_DATE.keys():
        rowStr = "%s,%s,%s,%s,%s,%s" % (prev_machine_id, d, DATA_BY_DATE[d][0], DATA_BY_DATE[d][1],DATA_BY_DATE[d][2], DATA_BY_DATE[d][3],)
        usage_each_date_domain = DATA_BY_DATE[d][4]
        for d in DOMAIN_LIST:
            if d in usage_each_date_domain.keys():
                rowStr = rowStr + ",%s,%s"%(usage_each_date_domain[d][0],usage_each_date_domain[d][1],)
            else:
                rowStr = rowStr + ",,"
        rowStr = rowStr + "\n"
        my_output_file.write(rowStr)
         
my_output_file.close()
#######################################DONE##############################################
print "Done, write the final output into file %s" %(FINAL_OUTPUT_FILE,)
        
            
        

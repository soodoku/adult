import time

URL_CATEGORY_FILE = "url_category.csv"
CATEGORY="Pornography"
INTERNET_USAGE_FILE = "../../../web_browsing_2004" #"8bdff911e30b975c.csv"#
FINAL_OUTPUT_FILE = "final_output_by_machineid_date.csv"


FINAL_OUTPUT_HEADER = "machine_id, date, total_pages_viewed, total_time_spent, total_domain_category_pages_viewed, total_domain_category_time_spent"

#############################READ DOMAIN LIST FILE#######################################
DOMAIN_LIST = []
print "Read the url category file %s" %(URL_CATEGORY_FILE,)
with open(URL_CATEGORY_FILE) as myfile:
        firstline = True
        for line in myfile:
            if firstline:
                firstline = False
                continue
            line = line.strip().replace("\n","")
            domain = line.split(',')[0]
            category = line.split(',')[1]
            if (len(domain)!=0 and category.lower()==CATEGORY.lower()):
                DOMAIN_LIST.append(domain)
print "Lengnth domain list  = %s\n" %(len(DOMAIN_LIST),) 

###############################START PROCESSING DATA#####################################
print "Start processing the data file %s" %(INTERNET_USAGE_FILE,)

my_output_file = open(FINAL_OUTPUT_FILE,"w")
my_output_file.write(FINAL_OUTPUT_HEADER + "\n")
    
fist_line = True
prev_machine_id = -1
DATA_BY_DATE = {}
count = 0
prev_timer = time.time()
DOMAIN_LIST = set(DOMAIN_LIST)
with open(INTERNET_USAGE_FILE) as myfile:
    for line in myfile:
        # Monitor the progress
        count = count + 1
        if (count%1000000==0):
            now = time.time()
            difference = int(now - prev_timer)
            print "   + Processing line %s.000.000th time_till_now=%s(s)"%(count/1000000,difference,)
        
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
                        rowStr = "%s,%s,%s,%s,%s,%s\n" % (prev_machine_id, d, DATA_BY_DATE[d][0], DATA_BY_DATE[d][1],DATA_BY_DATE[d][2], DATA_BY_DATE[d][3],)
                        my_output_file.write(rowStr)
                    
                    # Reset the log
                    
                    DATA_BY_DATE = {}
                    if (porn_domain_counted):
                        DATA_BY_DATE[date] = [pages_viewed, duration, pages_viewed, duration]
                    else:
                        DATA_BY_DATE[date] = [pages_viewed, duration, 0, 0]
                    prev_machine_id = machine_id
            else:
                    if date in DATA_BY_DATE.keys():
                        if (porn_domain_counted):
                            DATA_BY_DATE[date] = [DATA_BY_DATE[date][0] + pages_viewed, DATA_BY_DATE[date][1] + duration, DATA_BY_DATE[date][2] + pages_viewed, DATA_BY_DATE[date][3] + duration]
                        else:
                            DATA_BY_DATE[date] = [DATA_BY_DATE[date][0] + pages_viewed, DATA_BY_DATE[date][1] + duration, DATA_BY_DATE[date][2], DATA_BY_DATE[date][3]]
                    else:
                        if (porn_domain_counted):
                            DATA_BY_DATE[date] = [pages_viewed, duration, pages_viewed, duration]
                        else:
                            DATA_BY_DATE[date] = [pages_viewed, duration, 0, 0]
                            

    # Print the data for prev_machine_id
    for d in DATA_BY_DATE.keys():
        rowStr = "%s,%s,%s,%s,%s,%s\n" % (prev_machine_id, d, DATA_BY_DATE[d][0], DATA_BY_DATE[d][1],DATA_BY_DATE[d][2], DATA_BY_DATE[d][3],)
        my_output_file.write(rowStr)
         
my_output_file.close()
#######################################DONE##############################################
print "Done, write the final output into file %s" %(FINAL_OUTPUT_FILE,)
        
            
        

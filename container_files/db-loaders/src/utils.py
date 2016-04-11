import json, uuid, re

HEADER_COLOR        = '\033[95m'
BLUE_COLOR          = '\033[94m'
GREEN_COLOR         = '\033[92m'
WARNING_COLOR       = '\033[93m'
FAIL_COLOR          = '\033[91m'
END_COLOR           = '\033[0m'


def announcement_print(msg):
    print "" + WARNING_COLOR + str(msg) + END_COLOR
    return None
# end of announcement_print


def green_print(msg):
    print "" + GREEN_COLOR + str(msg) + END_COLOR
    return None
# end of green_print


def red_print(msg):
    print "" + FAIL_COLOR + str(msg) + END_COLOR
    return None
# end of red_print


def lg(msg, color_num):

    if   color_num == 4:
        announcement_print(msg)
    elif color_num == 5:
        green_print(msg)
    elif color_num == 6:
        print (msg)
    else:
        red_print(msg)

    return None
# end of lg


def build_unique_key(length=-1):
    return str(str(uuid.uuid4()).replace("-", "")[0:length])
# end of company_build_unique_key


def pretty_print_json(json_data):
    return str(json.dumps(json_data, sort_keys=True, indent=4, separators=(',', ': ')))
# end of pretty_print_json


def ppj(json_data):
    return str(json.dumps(json_data, sort_keys=True, indent=4, separators=(',', ': ')))
# end of ppj

    
def log_msg_to_unique_file(msg, path_to_file="/tmp/errors_to_look_at_"):

    log_file    = str(path_to_file) + str(uuid.uuid4()).replace("-", "") + ".log"
    with open(log_file, "w") as output_file:
        output_file.write(str(msg))

    return log_file
# end of log_msg_to_unique_file


def camel_case_string(name):
    output = ''.join(x for x in name.title() if not x.isspace()).replace("_", "")
    return output
# end of camel_case_string


def un_camel_case_string(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()
# end of un_camel_case_string
    
    
def build_dict(start_status="FAILED", start_error="", record={}):
    return  { "Status" : str(start_status), "Error" : str(start_error), "Record" : record }
# end of build_dict


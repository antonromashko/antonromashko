from grafana_api.grafana_face import GrafanaFace
import time
from datetime import datetime
import sys


grafana_api = GrafanaFace(auth=("admin", "admin"), host="localhost", port=3000)
start = time.mktime(datetime.strptime("2020-08-29 19:22:18", "%Y-%m-%d %H:%M:%S").timetuple())*1000
end = time.mktime(datetime.strptime("2020-08-29 19:32:18", "%Y-%m-%d %H:%M:%S").timetuple())*1000


def get_dashboard_id(uid):
    search = grafana_api.search.search_dashboards()
    result = list(filter(lambda x: x["uid"] == uid, search))
    return result[0]["id"]


def add_annotation(tag, description):
    annotation = grafana_api.annotations.add_annotation(
        dashboard_id=get_dashboard_id("wGw2fiDGz"),
        time_from=int(start),
        time_to=int(end),
        tags=[tag],
        text=description
    )
    print(annotation)
    return annotation


add_annotation(sys.argv[1], sys.argv[2])


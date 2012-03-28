create table if not exists repos (
  id integer primary key autoincrement,
  path varchar(50) not null,
  name varchar(50) not null,
  latest_commit varchar(40) not null,
  last_clock_in varchar(50),
  open integer
)
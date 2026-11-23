import database/main/models/grrr/gen/grrr
import glimr_sqlite/sqlite

pub fn delete_grrr(uuid: String) -> Bool {
  let pool = sqlite.start("main")
  let ok = case grrr.delete_by_uuid(pool, uuid) {
    Ok(_) -> True
    Error(_) -> False
  }
  ok
}

import glimr/db/schema

// docs: https://github.com/glimr-org/glimr?tab=readme-ov-file#migrations

pub const table_name = "grrrs"

pub fn definition() {
  schema.table(table_name, [
    schema.id(),
    schema.uuid("uuid"),
    schema.string("author_handle"),
    schema.text("body"),
    schema.timestamps(),
  ])
  |> schema.indexes([
    schema.unique(["uuid"]),
    schema.index(["author_handle"]),
  ])
}

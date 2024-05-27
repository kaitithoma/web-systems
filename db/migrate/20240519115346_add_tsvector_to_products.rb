class AddTsvectorToProducts < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION array_to_string_immutable(arr text[], sep TEXT)
      RETURNS text
      AS $$
        SELECT array_to_string(arr, sep);
      $$
      LANGUAGE SQL
      IMMUTABLE;
    SQL

    if Rails.env.test? || Rails.env.development?
      execute <<~SQL
        CREATE EXTENSION IF NOT EXISTS "unaccent";
      SQL

      execute <<~SQL
        CREATE OR REPLACE FUNCTION public.custom_unaccent(text)
        RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
        $func$
          SELECT public.unaccent('public.unaccent', $1)
        $func$;
      SQL
    end

    execute <<~SQL
      ALTER TABLE products
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        to_tsvector('simple', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('simple', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('english', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('english', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('greek', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('greek', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('german', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('german', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('french', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('french', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('italian', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('italian', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('spanish', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('spanish', custom_unaccent(array_to_string_immutable("products"."aliases", ' '))) ||
        to_tsvector('swedish', coalesce(custom_unaccent("products"."name"::text), '')) || to_tsvector('swedish', custom_unaccent(array_to_string_immutable("products"."aliases", ' ')))
      ) STORED;
    SQL

    add_index :products, :searchable, using: :gin, algorithm: :concurrently
  end

  def down
    remove_column :brands, :searchable
    remove_column :users, :searchable
    remove_column :products, :searchable
    remove_column :retailer_categories, :searchable
    remove_column :search_terms, :searchable
    remove_column :site_pages, :searchable

    execute <<~SQL
      DROP FUNCTION array_to_string_immutable;
    SQL
  end
end

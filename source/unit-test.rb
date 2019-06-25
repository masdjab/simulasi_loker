require 'test/unit'
require './loker'

class BackendTest < Test::Unit::TestCase
  def test_slot
    slot = Slot.new
    assert_equal true, slot.kosong?
    assert_equal nil, slot.jenis_identitas
    assert_equal nil, slot.nomor_identitas
    
    slot.pakai "KTP", "123456"
    assert_equal true, !slot.kosong?
    assert_equal "KTP", slot.jenis_identitas
    assert_equal "123456", slot.nomor_identitas
    
    slot.kosongkan
    assert_equal true, slot.kosong?
    assert_equal nil, slot.jenis_identitas
    assert_equal nil, slot.nomor_identitas
  end
  def test_loker
    loker = Loker.new(10)
    assert_equal true, loker.kosong?
    assert_equal true, !loker.penuh?
    assert_equal true, loker.where_are?(jenis_id: "KTP").empty?
    assert_equal true, loker.where_are?(jenis_id: "SIM").empty?
    assert_equal true, loker.where_are?(nomor_id: "123456").empty?
    assert_equal true, loker.where_are?(nomor_id: "654321").empty?
    assert_equal true, loker.where_are?(jenis_id: "KTP", nomor_id: "123456").empty?
    assert_equal true, loker.where_are?(jenis_id: "SIM", nomor_id: "654321").empty?
    assert_equal nil, loker.where_is?(jenis_id: "KTP")
    assert_equal nil, loker.where_is?(jenis_id: "SIM")
    assert_equal nil, loker.where_is?(nomor_id: "123456")
    assert_equal nil, loker.where_is?(nomor_id: "654321")
    assert_equal nil, loker.where_is?(jenis_id: "KTP", nomor_id: "123456")
    assert_equal nil, loker.where_is?(jenis_id: "SIM", nomor_id: "654321")
  end
  def test_app
    app = App.new
    assert_equal "  123  ", app.format(123, 7)
    assert_equal "'KTP'|'SIM'", app.valid_types_info
    assert_equal true, app.valid_type?("KTP")
    assert_equal true, app.valid_type?("SIM")
    assert_equal false, app.valid_type?("STNM")
  end
end

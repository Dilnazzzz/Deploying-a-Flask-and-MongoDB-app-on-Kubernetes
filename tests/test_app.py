import pytest

from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_healthz(client):
    resp = client.get("/healthz")
    assert resp.status_code == 200
    assert resp.is_json
    assert resp.get_json().get("status") == "ok"


def test_index(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.is_json
    assert "message" in resp.get_json()


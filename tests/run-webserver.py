# SPDX-FileCopyrightText: 2024 Damian Fajfer <damian@fajfer.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later
import pytest
import requests
import docker
import time
from os import environ


def wait_for_webserver(max_retries: int) -> requests.Response:
    for i in range(max_retries):
        try:
            response = requests.get("http://localhost:8080")
            response.raise_for_status()
            return response
        except requests.exceptions.ConnectionError:
            time.sleep(1)
    else:
        pytest.fail("Failed to connect to the webserver")


def test_webserver() -> None:
    client = docker.from_env()
    container = client.containers.run(
        environ["GCUPS_DOCKER_IMAGE"],
        ports={"8080/tcp": 8080},
        detach=True,
        remove=True,
    )

    server_response = wait_for_webserver(30)
    assert server_response.status_code == 200

    container.kill()
    client.close()

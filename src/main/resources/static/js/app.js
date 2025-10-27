async function invokeApi(){
  const endpoint = document.getElementById('endpoint').value;
  const method = document.getElementById('method').value;
  const outEl = document.getElementById('apiResult');
  outEl.textContent = 'Loading…';
  try {
    const res = await fetch(endpoint, {method});
    const text = await res.text();
    let pretty;
    try { pretty = JSON.stringify(JSON.parse(text), null, 2); } catch(_){ pretty = text; }
    outEl.textContent = `Status: ${res.status}\n\n${pretty}`;
  } catch (e) {
    outEl.textContent = 'Error: ' + e.message;
  }
}


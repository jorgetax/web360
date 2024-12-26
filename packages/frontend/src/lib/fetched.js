export default async function fetched(url, options) {
  try {
    const res = await fetch(url, options)

    if (!res.ok) return {status: res.status, error: res}

    const data = await res.json()

    return {status: res.status, data}
  } catch (error) {
    return {status: 500, error}
  }
}
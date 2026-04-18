import axios from 'axios'

export interface SimRequest {
  lam: number
  mu: number
  K: number
  sample_size?: number
  seed?: number | null
}

export interface SimResponse {
  times: number[]
  states: number[]
  wait_times?: number[]
  blocking_probability: number
  mean_wait: number
}

const api = axios.create({
  baseURL: 'http://127.0.0.1:8000',
  timeout: 120000,
})

export async function simulate(params: SimRequest): Promise<SimResponse> {
  const resp = await api.post<SimResponse>('/simulate', params)
  return resp.data
}

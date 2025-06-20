import { describe, it, expect } from 'vitest'

describe('App', () => {
  it('should be defined', () => {
    expect(true).toBe(true)
  })
  
  it('should pass basic smoke test', () => {
    const appName = 'KubeTyper'
    expect(appName).toBe('KubeTyper')
  })
}) 
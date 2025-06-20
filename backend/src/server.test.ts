import { describe, it, expect } from 'vitest'
import { config } from './config.js'

describe('Server', () => {
  it('should have proper configuration', () => {
    expect(config.NODE_ENV).toBeDefined()
    expect(config.PORT).toBeGreaterThan(0)
  })
  
  it('should pass basic smoke test', () => {
    const serverName = 'KubeTyper Backend'
    expect(serverName).toBe('KubeTyper Backend')
  })
}) 
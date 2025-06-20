# KubeTyper Deployment Test Script
# Comprehensive testing of the live application

Write-Host "🚀 Testing KubeTyper Deployment..." -ForegroundColor Green
Write-Host "=====================================`n" -ForegroundColor Green

$baseUrl = "http://kubetyper.your-domain.com"
$testResults = @()

# Test 1: Frontend Accessibility
Write-Host "1. Testing Frontend Accessibility..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri $baseUrl -TimeoutSec 10
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend is accessible (Status: $($frontendResponse.StatusCode))" -ForegroundColor Green
        $testResults += "Frontend: PASS"
    } else {
        Write-Host "   ❌ Frontend returned unexpected status: $($frontendResponse.StatusCode)" -ForegroundColor Red
        $testResults += "Frontend: FAIL"
    }
} catch {
    Write-Host "   ❌ Frontend is not accessible: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += "Frontend: FAIL"
}

# Test 2: Backend Health Check
Write-Host "`n2. Testing Backend Health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "$baseUrl/api/healthz" -TimeoutSec 10
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Backend health check passed (Status: $($healthResponse.StatusCode))" -ForegroundColor Green
        $testResults += "Backend Health: PASS"
    } else {
        Write-Host "   ❌ Backend health check failed: $($healthResponse.StatusCode)" -ForegroundColor Red
        $testResults += "Backend Health: FAIL"
    }
} catch {
    Write-Host "   ❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += "Backend Health: FAIL"
}

# Test 3: API Endpoints
Write-Host "`n3. Testing Core API Endpoints..." -ForegroundColor Yellow

# Test Text API
try {
    $textResponse = Invoke-WebRequest -Uri "$baseUrl/api/text" -TimeoutSec 10
    if ($textResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Text API is working (Status: $($textResponse.StatusCode))" -ForegroundColor Green
        $testResults += "Text API: PASS"
    } else {
        Write-Host "   ❌ Text API failed: $($textResponse.StatusCode)" -ForegroundColor Red
        $testResults += "Text API: FAIL"
    }
} catch {
    Write-Host "   ⚠️ Text API test inconclusive: $($_.Exception.Message)" -ForegroundColor Yellow
    $testResults += "Text API: INCONCLUSIVE"
}

# Test 4: Response Time
Write-Host "`n4. Testing Response Time..." -ForegroundColor Yellow
try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri $baseUrl -TimeoutSec 10
    $stopwatch.Stop()
    $responseTime = $stopwatch.ElapsedMilliseconds
    
    if ($responseTime -lt 2000) {
        Write-Host "   ✅ Response time is excellent: ${responseTime}ms" -ForegroundColor Green
        $testResults += "Response Time: PASS"
    } elseif ($responseTime -lt 5000) {
        Write-Host "   ⚠️ Response time is acceptable: ${responseTime}ms" -ForegroundColor Yellow
        $testResults += "Response Time: ACCEPTABLE"
    } else {
        Write-Host "   ❌ Response time is slow: ${responseTime}ms" -ForegroundColor Red
        $testResults += "Response Time: SLOW"
    }
} catch {
    Write-Host "   ❌ Response time test failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += "Response Time: FAIL"
}

# Test 5: Content Verification
Write-Host "`n5. Testing Content Delivery..." -ForegroundColor Yellow
try {
    $contentResponse = Invoke-WebRequest -Uri $baseUrl -TimeoutSec 10
    $content = $contentResponse.Content
    
    if ($content.Contains("<!doctype html>") -or $content.Contains("<!DOCTYPE html>")) {
        Write-Host "   ✅ HTML content is properly delivered" -ForegroundColor Green
        $testResults += "HTML Content: PASS"
    } else {
        Write-Host "   ❌ HTML content validation failed" -ForegroundColor Red
        $testResults += "HTML Content: FAIL"
    }
} catch {
    Write-Host "   ❌ Content verification failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += "HTML Content: FAIL"
}

# Test Summary
Write-Host "`n🎯 TEST SUMMARY" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
foreach ($result in $testResults) {
    Write-Host "   $result" -ForegroundColor White
}

# Final Assessment
$passCount = ($testResults | Where-Object { $_ -like "*PASS*" }).Count
$totalTests = $testResults.Count

Write-Host "`n📊 OVERALL ASSESSMENT" -ForegroundColor Magenta
Write-Host "=====================" -ForegroundColor Magenta
Write-Host "   Tests Passed: $passCount/$totalTests" -ForegroundColor White

if ($passCount -eq $totalTests) {
    Write-Host "   🎉 DEPLOYMENT SUCCESSFUL! All tests passed." -ForegroundColor Green
    Write-Host "   🚀 KubeTyper is LIVE and ready for users!" -ForegroundColor Green
} elseif ($passCount -ge ($totalTests * 0.8)) {
    Write-Host "   ✅ DEPLOYMENT MOSTLY SUCCESSFUL! Most critical tests passed." -ForegroundColor Yellow
    Write-Host "   🎮 KubeTyper is LIVE with minor issues." -ForegroundColor Yellow
} else {
    Write-Host "   ❌ DEPLOYMENT NEEDS ATTENTION! Multiple tests failed." -ForegroundColor Red
    Write-Host "   🔧 Please investigate the failed components." -ForegroundColor Red
}

Write-Host "`n🌐 Application URL: $baseUrl" -ForegroundColor Cyan
Write-Host "📝 You can now access KubeTyper at the above URL!" -ForegroundColor Cyan 
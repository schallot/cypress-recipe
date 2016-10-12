describe service 'nginx' do
  it { should be_installed }
  it { should be_running }
end

describe service 'mongod' do
  it { should be_enabled }
  it { should be_running }
end

describe service 'cypress' do
  it { should be_enabled }
  it { should be_running }
end

describe service 'cypress-validation-utility' do
  it { should be_enabled }
  it { should be_running }
end

describe command 'curl localhost/users/sign_in' do
  its('stdout') { should match /Sign In/ }
  its('stdout') { should match /Sign up/ }
  its('stdout') { should match /Cypress/ }
end

describe port 80 do
  it { should be_listening }
end

describe port 8080 do
  it { should be_listening }
end

describe command 'cat /sys/kernel/mm/transparent_hugepage/enabled' do
  its('stdout') { should match /\[never\]/ }
end

describe command 'cat /sys/kernel/mm/transparent_hugepage/defrag' do
  its('stdout') { should match /\[never\]/ }
end
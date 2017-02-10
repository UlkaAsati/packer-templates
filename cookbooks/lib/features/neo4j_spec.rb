def furbies
  @furbies ||= rand(200..299)
end

describe 'neo4j installation' do
  describe command('which neo4j') do
    its(:stdout) { should match 'bin/neo4j' }
  end

  describe 'neo4j commands', sudo: true do
    before :all do
      sh('sudo neo4j start')
      tcpwait('127.0.0.1', 7474)
      sh("neo4j-shell -c 'create (n:thing {furbies: #{furbies});'")
    end

    describe service('neo4j') do
      it { should be_running }
    end

    describe command("neo4j-shell -c 'cd 0; ls'"), precise: false do
      its(:stdout) { should include('furbies =', furbies.to_s) }
    end
  end
end

{

    foo => [

        #    { Check =>  ['Sleep',6],
        #      Action => ['Echo', 'This will never show up'], },

        {
            Check  => [ 'HTTP', 'http://www.optusnet.com.au' ],
            Action => [
                'RFC2136',
                {
                    nameserver => 'saito.fragfest.com.au',
                    domain  => 'bong.com.au',
                    name    => 'thisistest.bong.com.au',
                    ttl     => 7200,
                    type    => 'A',
                    content => '192.0.5.4'
                }
            ],
        },

        {
            Check  => [ 'HTTP', 'http://www.optusnet.com.au' ],
            Action => [
                'PowerDNS::BuiltInJsonApi',
                {
                    url     => 'http://saito.fragfest.com.au:8081/servers/localhost/zones/fragfest.com.au',
                    key     => 'fragfest',
                    name    => 'thisistest.fragfest.com.au',
                    ttl     => 86400,
                    type    => 'A',
                    content => '192.0.5.4'
                }
            ],
        },

        {
            Check  => [ 'Replay', 0 ],
            Action => [ 'Echo',   'This will never show up' ],
        },

        {
            Check  => 'LastResort',
            Action => [ 'Echo', 'If I die, tell my wife hello' ],
        },

    ],

}

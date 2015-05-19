{

    Store => {
        driver => 'Memory',
        global => 1
    },

    Checks => [

        {
            Check    => 'HTTP',
            Provide => 'WwwOptusnetComAuOK',
            url      => 'http://www.optusnet.com.au',
        },

        {
            Check    => 'Sleep',
            Provide => 'Sleep6',
            duration => 6
        },

        {
            Check    => 'True',
            Provide => 'AlwaysTrue',
        },

#        {
#            Check    => 'AnyOf',
#            Provide => 'ExampleAnyOf',
#            checks   => [ 'Sleep6', 'WwwOptusnetComAuOK' ],
#        },
#
#        {
#            Check    => 'AllOf',
#            Provide => 'ExampleAllOf',
#            checks   => [ 'Sleep6', 'WwwOptusnetComAuOK' ],
#        },
#
#        {
#            Check    => 'MostOf',
#            Provide => 'ExampleMostOf',
#            checks   => [ 'Sleep6', 'WwwOptusnetComAuOK' ],
#        },
#
#        {
#            Check    => 'NoneOf',
#            Provide => 'ExampleNoneOf',
#            checks   => [ 'Sleep6', 'WwwOptusnetComAuOK' ],
#        },

    ],

    Actions => [

#        {
#            Action     => 'RFC2136',
#            Trigger    => 'WwwOptusnetComAuOK',
#            nameserver => 'saito.fragfest.com.au',
#            domain     => 'bong.com.au',
#            name       => 'thisistest.bong.com.au',
#            ttl        => 7200,
#            type       => 'A',
#            content    => '192.0.5.4'
#        },

#        {
#            Action  => 'PowerDNS::BuiltInJsonApi',
#            Trigger => 'ExampleAnyOf',
#            url     => 'http://saito.fragfest.com.au:8081/servers/localhost/zones/fragfest.com.au',
#            key     => 'fragfest',
#            name    => 'thisistest.fragfest.com.au',
#            ttl     => 86400,
#            type    => 'A',
#            content => '192.0.5.4'
#        },

        {
            Action  => 'Echo',
            Trigger => 'AlwaysTrue',
            message => 'If I die, tell my wife hello'
        },

    ],

}

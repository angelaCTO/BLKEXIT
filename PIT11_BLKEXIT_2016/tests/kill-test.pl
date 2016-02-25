#!/usr/bin/env perl

use threads;
use threads::shared; # for shared variables

my $cnt :shared = 0;
my $toexit :shared = 0;


sub counter() {
  $SIG{'INT'} = sub { print "Thread exit\n"; threads->exit(); };
  my $lexit = 0;
  while (not($lexit)) {
    { lock($toexit);
    $lexit = $toexit;
    }
    $cnt++;
    print "thread: $cnt \n";
    sleep 1;
  }
  print "out\n";
}

my $mthr;

sub finisher{
  { lock($toexit);
  $toexit = 1;
  }
  $mthr->kill('INT');
};

$SIG{INT} = \&finisher;

$mthr = threads->create(\&counter);


print "prejoin\n";
#~ $mthr->join();

while (threads->list()) {
   my @joinable = threads->list(threads::joinable);
   if (@joinable) {
      $_->join for @joinable;
   } else {
      sleep(0.050);
   }
}
print "postjoin\n";
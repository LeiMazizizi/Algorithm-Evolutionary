use ExtUtils::MakeMaker;

my @scripts = grep {-f } glob("scripts/*.pl "); # Ripped from Text::PDF

WriteMakefile(
    NAME                => 'Algorithm::Evolutionary',
    AUTHOR              => 'JJ Merelo <jj /at/ merelo.net>',
    VERSION_FROM        => 'lib/Algorithm/Evolutionary.pm',
    ABSTRACT_FROM       => 'lib/Algorithm/Evolutionary.pm',
    EXE_FILES => \@scripts,
    LICENSE => 'gpl',
    PL_FILES            => {},
    PREREQ_PM => {'Algorithm::Permute' => 0.01,
		  'B::Deparse' => 0.56,
		  'Bit::Vector' => 0,
		  'Clone' => 0.31,
		  constant => 0,
		  'GD' => 2.17,   
		  'Math::Random' => 0.63,
		  'Memoize' => 0, 
		  'Object::Array' => 0,
		  'Pod::Escapes'	=> '0', #Dependence from Test::Pod, but produces failure in 1 platform
		  'Sort::Key' => 0,		  
		  'Statistics::Basic' => 1.6,
		  'String::Random' => 0,
		  'Test::More' => 0,
		  'Test::Pod' => 0,
		  'Test::Simple' => 0.44,
		  'Time::HiRes' => 0,
		  'Tree::DAG_Node' => 1.04,
		  'version'    => 0,
		  'XML::Parser' => 2.40,
		  'XML::Parser::Style::EasyTree' => 0,
		  'XML::LibXML' => 1.50,
		  YAML => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean               => { FILES => 'Algorithm-Evolutionary-*' }
    );

#Add new targets
sub MY::postamble {
    return <<'MAKE_FRAG';
docs:
	pod2html --verbose --htmlroot .. --podpath=Evolutionary/Individual:Evolutionary/Op:Evolutionary --outfile index.html Evolutionary.pm; \
	cd examples; for i in *.pl; do pod2html --verbose --htmlroot ../..  --podpath=../Evolutionary/Individual:../Evolutionary/Op:../Evolutionary --outfile $$i.html $$i; done ; \
	cd ../Evolutionary; for i in *.pm; do base=`basename $$i .pm`; echo $$base; pod2html --verbose --htmlroot ../.. --podpath=Individual:Op --outfile $$base.html $$i; done ; \
	for i in *.pod; do base=`basename $$i .pod`; echo $$base; pod2html --verbose --htmlroot ../..   --podpath=Individual:Op --outfile $$base.html $$i; done; \
	cd Op; for i in *.pm; do base=`basename $$i .pm`; echo $$base; pod2html --verbose --htmlroot ../../.. --podroot ..  --outfile $$base.html $$i; done ; \
	cd ../Individual; for i in *.pm; do base=`basename $$i .pm`; echo $$base; pod2html --verbose --htmlroot ../../.. --podroot .. --outfile $$base.html $$i; done
	
$(DISTVNAME)-examples.tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME)-examples.tar $(DISTVNAME)/examples
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME)-examples.tar
	$(POSTOP)

examplesdist : $(DISTVNAME)-examples.tar$(SUFFIX)
	$(NOECHO) $(NOOP)


MAKE_FRAG
}

#$Revision: 3.7 $

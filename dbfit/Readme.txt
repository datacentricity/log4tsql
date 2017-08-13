Dbfit is type of wiki that allows database regression tests to be written in a non-technical way (e.g. by users)
and is presented as a set of HTML pages. Dbfit also lends itself to use by database developers needing to create
re-runnable integration tests. The resulting test definitions can be added to source control to be shared with
the entire team.

Getting Started...
===========================================================

1) In a command prompt, navigate to Z:\Documents\_dev\trunk\DbFit\

2) Run "startFitnesse" (without the quotes) to start a local instance of the Fitnesse web server

3) Using Internet Explorer, go to http://localhost:8085/ which is the entry point for our test suite

4) Before writing any tests, please read the following:

	a) Z:\Documents\_dev\trunk\DbFit\docs\dbfit-docs-20080310.pdf to understand how to use DbFit

	b) http://localhost:8085/TutorialTestSuite.ReadMeFirst to understand how we are structuring and
	   writing our tests


Trouble shooting
===========================================================
This version of FitNesse has been compiled for Java v1.6. Occassionally, Windows jmay register the incorrect
java version and when you first run startFitnesse at step (2) above, you may see an error relating to
incorrect java version.  In this scenario, you need to start by identifying the correct path to the v1.7
java runtime engine, e.g. "C:\Program Files\Java\jre7".

Then in a Windows command prompt, run the following two commands:

	set JAVA_HOME=C:\Program Files (x86)\Java\jre7

	set PATH=%JAVA_HOME%\bin;%PATH%

When you retry startFitnesse it should now work.


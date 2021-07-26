//
//  QB_jsonNodes.h
//  QbankServer
//
//  Created by Ryan Landvater on 8/3/20.
//  Copyright © 2020 Ryan Landvater. All rights reserved.
//

#ifndef QB_jsonNodes_h
#define QB_jsonNodes_h

// This will either access the DEBUG database
// or the production database
#ifdef QB_DEBUG
#define __DATABASE__        "Qbank_DEBUG_2"
#else
#define __DATABASE__        "QBank"
#endif

#define __USERS__           "users"
#define __QUESTIONBANK__    "questionBank"
#define __TESTBANK__        "testBank"
#define __SHAREDTESTBANK__  "sharedTestBank"

#define __REQUEST       "QB_Request"
#define __OBJECTREQUEST "QB_ObjectRequest"
#define __RESPONSE      "QB_Response"
#define __OBJECTRESP    "QB_ObjectResponse"
#define __SHUTDOWN      "Shutdown"

#define __LOGINREQUEST  "LoginRequest"
#define __LOGOUTREQUEST "LogoutRequest"
#define __LOGOUT        "LogoutNotification"
#define __CREDENTIALS   "Login"
#define __USERNAME      "Username"
#define __PASSWORD      "Password"
#define __UPDATEPASS    "UpdatePassword"
#define __BIN_PROTOCOL  "BinaryProtocol"

#define __SESSION       "SessionToken"
#define __SID           "SessionID"
#define __EXPIRATION    "ExpirationTime"
#define __NEWSESSION    "RefreshSessionToken"

#define __NOTIFICATION  "Notification"
#define __STATISTICS    "Statistics"
#define __SETTINGS      "Settings"
#define __TITLE         "Title"

#define __UID           "UserID"
#define __FIRSTNAME     "UserFirstName"
#define __LASTNAME      "UserLastName"
#define __AUTHORROLE    "UserAuthorRole"
#define __ADMIN         "UserAdminRole"
#define __USED          "UsedQuestions"

#define __TID           "TestID"
#define __USERTESTS     "UserTests"
#define __INCOMPTESTS   "IncompleteTests"
#define __FINISHEDTESTS "FinishedTests"
#define __TESTREQUEST   "TestGenRequest"
#define __CURRENTTEST   "CurrentTest"
#define __PAUSETEST     "PauseTest"
#define __SUBMITTEST    "SubmitTest"
#define __RESUMETEST    "ResumeTest"
#define __COMPLETED     "TestCompleted"
#define __STATUS        "QuestionStatus"
#define __TOPICS        "TestTopics"
#define __TOPICNAME     "TopicName"
#define __DIAGNOSIS     "TestDiagnosis"
#define __TAGS          "TestTags"
#define __TESTNUMBER    "UserTestNumber"
#define __NUMBER        "Number"
#define __JMODE         "JMode"

#define __UNUSED        "Unused"
#define __CORRECT       "Correct"
#define __INCORRECT     "Incorrect"
#define __MARKED        "Marked"
#define __ALL           "All"

#define __QID           "QuestionID"
#define __NEWQUESTION   "NewQuestion"
#define __VIEWQUESTION  "ViewQuestion"
#define __EDITQUESTION  "EditQuestion"
#define __ANALYZEQUESTION "AnalyzeQuestionPerformance"
#define __EDITFIELD     "EditQuestionField"
#define __EDITARRAY     "EditQuestionArray"
#define __DELETE        "DeleteQuestion"
#define __PUBLISH       "PublishQuestion"
#define __QUESTIONFIELD "QuestionFields"
#define __QUESTIONNAME  "QuestionName"
#define __CLINICALHX    "ClinicalHistory"
#define __QUESTIONTXT   "QuestionText"
#define __NIMAGES       "NumberOfImages"
#define __CORRECTANSWER "CorrectAnswerIndex"
#define __EXPLAINATION  "ExpainationText"
#define __AUTHOR        "Author"
#define __COLLABORATORS "Collaborators"
#define __PUBLISHEDFLAG "Published"
#define __UPDATED       "Updated"
#define __PERFORMANCE   "Performance"

#define __QUESTIONS     "Questions"
#define __INCOMPLETE    "IncompleteQuestions"
#define __PUBLISHED     "PublishedQuestions"
#define __UPDATECHOICE  "UpdateChoice"
#define __SELECTION     "ChoiceSelection"
//#define __LOCKED        "SelectionLocked"
#define __SKIP          "StartAt"

#define __CHOICES       "AnswerChoiceArray"
#define __NEWCHOICE     "NewChoice"
#define __EDITCHOICE    "EditChoice"
#define __REMOVECHOICE  "RemoveChoice"
#define __CHOICENUMBER  "NumberOfChoices"
#define __CID           "ChoiceID"
#define __CHOICETEXT    "ChoiceText"
#define __SELECTCHOICE  "SelectChoice"
#define __SUBMITCHOICE  "SubmitChoice"
#define __CHOICECHANGED "ChoiceChanged"
#define __CHOICEEXP     "ChoiceExplanation"
#define __SUBMITTED     "ChoiceSubmitted"

#define __FILENAME      "FileName"
#define __FILESIZE      "FileSize"
#define __FILEDATA      "RawData"
#define __FILEPATH      "FilePath"
#define __FILEMETADATA  "FileMetadata"

#define __IMGID         "ImageID"
#define __NEWIMAGE      "NewImage"
#define __SENTIMAGE     "SentImage"
#define __REMOVEIMAGE   "RemoveImage"

#define __SHAREDTEST    "SharedTest"
#define __SHAREDTESTS   "SharedTestList"
#define __NEWSHARED     "NewSharedTest"
#define __EDITSHARED    "EditSharedTest"
#define __UPDATESHARED  "UpdateSharedTest"
#define __UPDATETYPE    "UpdateType"
#define __ADDQUESTION   "AddQuestion"
#define __RMQUESTION    "RemoveQuestion"
#define __ADDUSER       "AddUser"
#define __RMUSER        "RemoveUser"
#define __STID          "SharedTestID"
#define __TESTNAME      "SharedTestName"
#define __TIDS          "DelegateTestIDs"
#define __UIDS          "UserIDs"
#define __QIDS          "QuestionIDs"
#define __RMST          "RemoveSharedTest"

#define __SEARCH        "SearchRequest"
#define __SOUNDEX       "SoundexCode_en"
#define __CRITERION     "SearchCriterion"
#define __SEARCHTERMS   "SearchTerm"
#define __SEARCHRESULTS "SearchResults"

#endif /* QB_jsonNodes_h */

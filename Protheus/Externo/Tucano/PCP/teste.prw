DEFINE DIALOG oDlg TITLE "" FROM 180,180 TO 550,700 PIXEL
  oScroll := TScrollArea():New(oDlg,01,01,100,100)
  oScroll:Align := CONTROL_ALIGN_ALLCLIENT
 
  @ 000,000 MSPANEL oPanel OF oScroll SIZE 1000,1000 COLOR CLR_HRED
 
  TButton():New( 10,010,"Botão Teste",oPanel,{||},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 10,230,"Botão Teste",oPanel,{||},40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
 
  oScroll:SetFrame( oPanel )
ACTIVATE DIALOG oDlg CENTERED

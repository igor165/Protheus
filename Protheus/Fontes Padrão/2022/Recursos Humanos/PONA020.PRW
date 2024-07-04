#INCLUDE "PONA020.CH"
#INCLUDE "PROTHEUS.CH"              

Static lPntGrv := ExistBlock( "PNA020GRV" )

//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
Static lIntegDef := FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI")
                                   
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё PONA020  Ё Autor Ё Equipe Advanced RH    Ё Data Ё05/02/1996Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cadastramento de Feriados.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAPON                                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠╠╠╠╠╠
╠╠цддддддддддддбддддддддбдддддддддддбдддддддддддддддддддддддддддддддддддддадддд©╠╠
╠╠ЁProgramador Ё Data   Ё BOPS/FNC  Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддедддддддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁMarinaldo   Ё11/09/01ЁMelhor     ЁTratamento para Feriado Fixo              Ё╠╠  
╠╠ЁAdemar Jr.  Ё14/10/08Ё154183     ЁRetirado do objeto oMsFilial a reclassifi-Ё╠╠  
╠╠Ё            Ё        Ё           Ёcacao das variaveis de  Scroll existentes Ё╠╠  
╠╠Ё            Ё        Ё           Ёna primeira MsSelect da Tela de Copia.    Ё╠╠
╠╠ЁLeandro Dr. Ё31/03/09Ё007946     ЁInclusao de P.E. PNA020GRV.               Ё╠╠ 
╠╠ЁFrancisco JrЁ03/02/10Ё001881     ЁCompatibilizado para Gestao Corporativa   Ё╠╠
╠╠цддддддддддддеддддддддедддддддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRodrigo L.  |08/12/10Ё00259532010ЁAjuste de rotinas dos mСdulos p/          Ё╠╠ 
╠╠Ё            Ё--------Ё-----------Ёatender a Nova Interface Totvs 11         Ё╠╠
╠╠Ё            Ё--------Ё-----------Ёutilizando a funГЦo MsAdvSize(p/          Ё╠╠
╠╠Ё            Ё--------Ё-----------Ёflexibilidade da tela de acordo           Ё╠╠ 
╠╠Ё            Ё--------Ё-----------Ёcom a resoluГЦo). E reescrita das         Ё╠╠
╠╠Ё            Ё--------Ё-----------Ёjanelas que ainda possuem Barra           Ё╠╠
╠╠Ё            Ё        Ё           Ёde botУes, para utilizaГЦo da Enchoicebar.Ё╠╠
╠╠ЁAdemar Jr.  Ё01/02/11Ё002358/2011Ё-PTG-Implementado chamada do Pona440 (NovoЁ╠╠
╠╠Ё            Ё        Ё           Ё Cadastro de Feriados).                   Ё╠╠
╠╠ЁAlex FagundeЁ02/06/11Ё011916/2011ЁAlterada a Function At020ChgDia, variavel Ё╠╠
╠╠Ё            Ё        Ё           Ё dData perdia o valor.                    Ё╠╠
╠╠ЁAlex FagundeЁ05/07/11Ё015360/2011ЁAlterada a Function At020ChgDia, onde tem Ё╠╠
╠╠Ё            Ё        Ё           Ёa Variavel dData que estava sendo modific.Ё╠╠
╠╠ЁEmerson     Ё07/07/11Ё012949/2011ЁAtender a Nova Interface Totvs 11.5 utili-Ё╠╠
╠╠ЁCampos      Ё        Ё           Ёzando a funcao MsAdvSize( p/ flexibilidadeЁ╠╠
╠╠Ё            Ё        Ё           Ёda tela de acordo com a resolucao).       Ё╠╠ 
╠╠ЁAldo Marini Ё05/07/11Ё014243/2011ЁPreparacao para integracao do SIGAPON com Ё╠╠
╠╠Ё            ЁSDQY07  Ё           Ёo TSA (Totvs Controle de Acesso) via Web  Ё╠╠
╠╠Ё            Ё        Ё  	        Ёservices, desenvolvidos pela Datasul.	   Ё╠╠
╠╠ЁChristiane VЁ27/10/11Ё027044/2011ЁPosicionar feriado na visualizaГЦo, corre-Ё╠╠
╠╠Ё            Ё        Ё           ЁГЦo da alteraГЦo e incl.do botЦo "Excluir"Ё╠╠  
╠╠ЁGlaucia M.  Ё24/04/12Ё010247/2012ЁAjuste Telas, GestЦo Corporativa, exclusaoЁ╠╠
╠╠Ё            Ё        Ё     TEWEH3Ёferiados em outras filiais.			   Ё╠╠                   
╠╠ЁLuis Artuso Ё15/02/13Ё001946/2013ЁAjuste para verificar alteracao do tipo deЁ╠╠
╠╠Ё            Ё        Ё     TGKRSYЁferiado (fixo ou nao fixo),se o mesmo exisЁ╠╠   
╠╠Ё            Ё        Ё           Ёtir em anos anteriores.                   Ё╠╠
╠╠ЁGustavo M.  Ё15/04/13Ё006589/2013ЁAjuste ao tentar excluir feriado fixo em  Ё╠╠
╠╠Ё            Ё        Ё     TGWMBTЁano diferente da inclusao do mesmo.	   Ё╠╠
╠╠ЁLuis Artuso Ё01/08/13Ё018186/2013ЁAjuste na replica de feriados. Ao efetuar Ё╠╠
╠╠Ё            Ё        Ё     THOIO4Ёa replica para outras filiais os feriados Ё╠╠
╠╠Ё            Ё        Ё           Ёanteriormente cadastrados eram excluidos. Ё╠╠
╠╠ЁGustavo M.  Ё06/08/13Ё	  THOIO4ЁAjuste para nao excluir de forma indevida Ё╠╠
╠╠Ё            Ё        Ё     	 	Ёo feriado de outras filiais.			   Ё╠╠
╠╠ЁEmerson CampЁ23/01/15Ё	  TRKQPMЁAjuste para validar a posiГЦo correta da  Ё╠╠
╠╠Ё            Ё        Ё     	 	 Ё chamada de funГЦo dentro do stack	   Ё╠╠
╠╠ЁAllyson M.  Ё16/10/15Ё	  TTPMJ1ЁAjuste p/ integracao com TSA no metodo    Ё╠╠
╠╠ЁOswaldo L.  Ё03/04/17ЁDRHPONTP-164  ЁProjeto cTree                          Ё╠╠
╠╠ЁRaquel H.   Ё20/09/17Ё   MA3A-764ЁChanges for Russia Localization.          Ё╠╠
╠╠юддддддддддддаддддддддадддддддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PONA020(aCab,nOpcAuto)

Local aArea			:= GetArea()

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	 := {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Size		:= {}
Local aObj1Coords	:= {}


Local oDlg
Local oCalend
Local aBotoes     	:= 	{}   
Local bSet24		:=	{ || oDlg:End()  }
Local bCalend		:=	{}
Local nRecno		:=	SP3->(Recno())
                              
Local bfCopiaFeriado:= {|| IF (fProgAtual(),;
								 fChamaTelaCopia(	cFilSP3			,; // Filial do SP3
													oCalend			,; // Objeto Calendario
													lSP3Exclusivo	,; // Indica se o SP3 eh exclusivo
													cAliasTmp1		,; //	Alias do temporario para selecao de filiais
													cAliasTmp2		,; //	Alias do temporario com dados da filial origem do feriado
													cMark			,; //	Marca do MarkBrowse
													aBrowseFields	; //	Campos a serem mostrados no MarkBrowse
												),;		
							 	Nil;
							 );			  		
					   }
Local aSvKeys		:= GetKeys() 

Local aBrowseFields		:= {}    

 
Local cAliasTmp1		:= GetNextAlias()  
Local cAliasTmp2		:= GetNextAlias()  
Local cMarca			:= GetMark()

Default nOpcAuto		:= 0
Default aCab			:= {}

Private oTmp1Tab
Private oTmp2Tab

Private lAutoExec		:= Len(aCab) > 0 .AND. nOpcAuto > 0 

Private cFilSP3 		:= xFilial("SP3")  
Private lSP3Exclusivo	:= (Len(xFilial("SP3")) == FwGetTamFilial)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chamada do Novo Cadastro de Feriados.                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cPaisLoc $ "PTG" .And.;
	SP3->( Type("P3_TIPO") # "U" .And. Type("P3_TIPCOD") # "U" .And. Type("P3_GCFIL") # "U" )
	
	Pona440()
	Return
EndIf

Private cMarK			:= GetMark()  
Private cSpaceMarca		:= Space(Len(cMark))

	/*
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Define o Bloco de Definicao de Botoes 	   	   			   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
    //-- Somente disponbiliza botao de copia de feriado quando a 
    //-- tabela de feriado for exclusiva

	IF lSP3Exclusivo 
		 aAdd(; 
				aBotoes	,;
								{;
									"BMPCPO"				,;	 
		   							bfCopiaFeriado			,;
		       	   					OemToAnsi( STR0029 )	,; //"Copia Feriado <F4>..."
		       	   					OemToAnsi( STR0029 )	;  //"Copia"
		           				};
		    )	


		 SetKey(VK_F4,bfCopiaFeriado)
		/*
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Cria um Arquivo temporario com as filiais disponiveis		   Ё
		Ё para o Usuario para posterior replicaГЦo dos feriados		   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		CriaArqFil(cMarca, @aBrowseFields, cAliasTmp1, cAliasTmp2, cFilSP3)

    EndIF

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Inicializa __aStaticFeriado                                 Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RstfFeriado()


/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Monta as Dimensoes dos Objetos         					   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If lAutoExec
	At020ChgDia( @oCalend, cFilSP3,lSP3Exclusivo, cAliasTmp1, aCab, nOpcAuto)
Else
	aAdvSize	:= MsAdvSize(,.T.,380)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 1 , 1 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } ) 			//Linha 1
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } ) 			//Linha 2
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } ) 			//Linha 3			
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords ) 
	
	//Divisao em colunas Linha 2-Para centralizacao do calendАrio
	aAdv1Size		:= aClone(aObjSize[2])
	aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//Coluna Esquerda	
	aAdd( aObj1Coords , { 120 , 000 , .F. , .T. } )			//Coluna Central
	aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//Coluna Direita
	aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )   
	
	DEFINE DIALOG oDlg TITLE STR0015 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]  PIXEL // "Calendario - Feriados"
	
	oCalend:=MsCalend():New(aObj1Size[2,1],aObj1Size[2,2],oDlg)
	
	oCalend:dDiaAtu		:= dDataBase
	oCalend:bChange 	:= {|| oCalend:CtrlRefresh() }    
	oCalend:bLDblClick	:= {|| At020ChgDia( @oCalend, cFilSP3,lSP3Exclusivo, cAliasTmp1), oDlg:Refresh(), oCalend:CtrlRefresh() }
	oCalend:bChangeMes	:= {|| At020ChgMes( @oCalend, cFilSP3,lSP3Exclusivo, cAliasTmp1), oDlg:Refresh(), oCalend:CtrlRefresh() }
	
	ACTIVATE MSDIALOG oDlg ON INIT (enchoicebar(oDlg,bSet24, bSet24,,aBotoes),;
									At020ChgMes( @oCalend, cFilSP3,lSP3Exclusivo, cAliasTmp1),;
									oCalend:CtrlRefresh();
									) CENTERED		//Ok e cancelar terЦo o mesmo efeito, ou seja sair
EndIf								
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Para SP3 exclusivo										   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
IF lSP3Exclusivo 
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Elimina Arquivo Temporario e Indice						   Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !Empty(Select(cAliasTmp1))
		dbSelectArea(cAliasTmp1)
		dbCloseArea()
		If oTmp1Tab <> Nil
		    oTmp1Tab:Delete()
		    Freeobj(oTmp1Tab)
	    EndIf
	
	EndIF
	
	If !Empty(Select(cAliasTmp2))
		dbSelectArea(cAliasTmp2)
		dbCloseArea()
		If oTmp2Tab <> Nil
		    oTmp2Tab:Delete()
		    Freeobj(oTmp2Tab)
	    EndIf
	
	EndIF
EndIF

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Destroi __aStaticFeriado                                    Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RstfFeriado()
RestKeys( aSvKeys , .T. )  
RestArea(aArea)

Return( NIL )


/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁAt020ChgMesЁ Autor ЁMarinaldo de Jesus    Ё Data Ё08/08/2001Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Atualizar os dias do calendario                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PONA020                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function At020ChgMes(oCalend, cFilSP3,lSP3Exclusivo, cAliasTm1)

Local aAreaSP3	:= SP3->( GetArea() )

Local cMes		:= ""
Local dPrimAtu 	:= Ctod("01/"+StrZero(Month(oCalend:dDiaAtu),02)+"/"+StrZero(Year(oCalend:dDiaAtu),04),'ddmmyy')
Local dPrimAnt	:= ( ( dPrimAtu - 1	) - ( Day( ( dPrimAtu - 1 ) ) - 1 ) )
Local dPrimPos	:= ( LastDay( dPrimAtu ) + 1 )
Local nMonth	:= 0
Local nYear		:= 0

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVerifica os Feriados do Mes Anterior                         Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
dbSelectArea("SP3")
SP3->( dbSetOrder(01) )
SP3->( dbSeek(cFilSP3+Dtos(dPrimAnt),.T.) )
nMonth	:= Month(dPrimAnt)
nYear	:= Year(dPrimAnt)
While SP3->( !Eof() .and. P3_FILIAL == cFilSP3 .and. ;
						  ( nMonth == Month( P3_DATA ) ) .and. ;
						  ( nYear == Year( P3_DATA ) );
			)
		
		oCalend:addR_Prev(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)   
		   
	    SP3->( dbSkip() )
EndDo

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVerifica os Feriados Fixos do Mes Anterior                   Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
dbSelectArea("SP3")
SP3->( dbSetOrder(02) )
cMes := StrZero( Month(dPrimAnt) , 2 )
SP3->( dbSeek(cFilSP3+cMes,.T.) )
While SP3->( !Eof() .and. P3_FILIAL == cFilSP3 .and. cMes == Substr( P3_MESDIA , 1 , 2 ) )
		IF SP3->P3_FIXO == "S"
			oCalend:addR_Prev(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)
		EndIF	
	
      SP3->( dbSkip() )
EndDo

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVerifica os Feriados do Mes Posterior                        Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
dbSelectArea("SP3")
SP3->( dbSetOrder(01) )
SP3->( dbSeek(cFilSP3+Dtos(dPrimPos),.T.) )
nMonth	:= Month(dPrimPos)
nYear	:= Year(dPrimPos)
While SP3->( !Eof() .and. P3_FILIAL == cFilSP3 .and. ;
						  ( nMonth == Month( P3_DATA ) ) .and. ;
						  ( nYear == Year( P3_DATA ) );
			)
		oCalend:addR_Next(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)  
		
		SP3->( dbSkip() )
EndDo

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVerifica os Feriados Fixos do Mes Posterior                  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
dbSelectArea("SP3")
SP3->( dbSetOrder(02) )
cMes := StrZero( Month(dPrimPos) , 2 )
SP3->( dbSeek(cFilSP3+cMes,.T.) )
While SP3->( !Eof() .and. P3_FILIAL == cFilSP3 .and. cMes == Subst( P3_MESDIA , 1 , 2 ) )
		IF SP3->P3_FIXO == "S" 
			oCalend:addR_Next(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)
		EndIF	

      SP3->( dbSkip() )
EndDo

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVerifica os Feriados do Mes Atual		                      Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
dbSelectArea("SP3")
SP3->( dbSetOrder(01) )
SP3->( dbSeek(cFilSP3+Dtos(dPrimAtu),.T.) )
nMonth	:= Month(dPrimAtu)
nYear	:= Year(dPrimAtu)
While SP3->( !Eof() .and. P3_FILIAL == cFilSP3 .and. ;
						  ( nMonth == Month( P3_DATA ) ) .and. ;
						  ( nYear == Year( P3_DATA ) );
			)
		oCalend:AddRestri(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)

      SP3->( dbSkip() )
EndDo

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁVerifica os Feriados Fixos do Mes Atual		              Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
dbSelectArea("SP3")
SP3->( dbSetOrder(02) )
cMes	:= StrZero( Month(dPrimAtu) , 2 )
SP3->( dbSeek(cFilSP3+cMes,.T.) )
While SP3->( !Eof() .and. P3_FILIAL == cFilSP3 .and. cMes == Substr( P3_MESDIA , 1 , 2 ) )
		IF SP3->P3_FIXO == "S"
			oCalend:AddRestri(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)
		EndIF

      SP3->( dbSkip() )
EndDo

RestArea( aAreaSP3 )

Return( .T. )    

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfFilFerDia   Ё Autor ЁMauricio MR		   Ё Data Ё21/12/06  Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIdentifica as filiais que possuem feriado no dia atual		 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPona020	                                                     Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function fFilFerDia(		oCalend			,; 	// Objeto Calendario
							 	cAliasTmp1		,;	// Alias do arquivo temporario com as filiais para selecao
						        lSP3Exclusivo    ;
						  )   
Local aAliasArea	:= (cAliasTmp1)->(GetArea())  
Local aSP3Area		:= SP3->(GetArea())

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁCorre o arquivo Temporario para verificar as filiais que pos-Ё
Ёsuem feriado para o dia.									  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If lSP3Exclusivo

	dbSelectArea(cAliasTmp1)

	(cAliasTmp1)->(DbGotop())

	While (cAliasTmp1)->( !Eof() )
				
		IF ( fFeriado( (cAliasTmp1)->M0_CODFIL , oCalend:dDiaAtu ) ) 
			(cAliasTmp1)->(TrataArq(FWGETCODFILIAL,  lSP3Exclusivo, cAliasTmp1, Recno() ))
		Else
			(cAliasTmp1)->(TrataArq(FWGETCODFILIAL,  lSP3Exclusivo, cAliasTmp1, Recno(),.T. ))    
		Endif
		(cAliasTmp1)->( dbSkip() )
		
	EndDo         
	RestArea(aSP3Area)
	RestArea(aAliasArea)
EndIf

Return (Nil)

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁAt020chgdiaЁ Autor ЁAldo Marini Junior    Ё Data Ё09/06/1999Ё╠╠
╠╠Ё          ЁAt020chgdiaЁ Autor ЁMarinaldo de Jesus    Ё Data Ё08/08/2001Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Validar os dias do calendario                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PONA020                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function At020ChgDia(oCalend,cFilSP3,lSP3Exclusivo, cAliasTmp1, aCab, nOpcAuto)

Local aArea			:= GetArea()
Local aKeys			:=GetKeys() 
Local aAreaSP3		:= SP3->( GetArea() )
Local aAreaSX3		:= SX3->( GetArea() )
Local aNormal		:= {}
Local aNoturna		:= {}
Local aFixo	 		:= {}
Local aTpDay		:= {}
Local cDescricao	:= ""
Local cDesc     	:= ""
Local cData			:= ""
Local cTpNormal 	:= ""
Local cTpNoturn 	:= ""
Local cTpFixo   	:= ""
Local cDTpDay		:= ""
Local cSvTpFix		:= ""
Local cMsgErr		:= ""
Local cP3MesDia		:= Space( TamSx3( "P3_MESDIA" )[1] )
Local dDataFix		:= Ctod("//")
Local lInclusao		:= .F.
Local lLock			:= .F.
Local nOpcA			:= 0
Local nLastRec		:= 0

Local oDlg2
Local oGet
Local oBut1
Local oFont

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords	:= {}
Local aObjSize		:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Coords	:= {}
Local aObj1Size		:= {}

Local bSet15		:= {||}
Local bSet24		:= {||}
Local aButtons		:= {}

Local lTSREP		:= SuperGetMv( "MV_TSREP" , NIL , .F. )

Local nPosCab		:= 0
Local lP020Auto	:= .F.
Local aAreaAuto	:= {}

Default aCab		:= {}
Default nOpcAuto	:= 0

Private oObjREP	:= Nil

Private cTpExt
Private cTpExtN
Private cFerFix
Private cTpDay
Private dData			:= Ctod("//")

//Execauto
lP020Auto := Len(aCab) > 0 .AND. nOpcAuto > 0
 
/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Monta os Arrays para Selecao nos COMBOBOX                   Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
aNormal  	:= Sx3Box2Arr( "P3_TPEXT"  )
aNoturna	:= Sx3Box2Arr( "P3_TPEXTN" )
aFixo		:= Sx3Box2Arr( "P3_FIXO"   )
If cPaisLoc == "RUS"
	aTpDay		:= Sx3Box2Arr( "P3_TPDAY"   )
EndIf

//Execauto
If 	lP020Auto
	If Type("lMsErroAuto") != "L"
		lMsErroAuto := .F.
	EndIf
	
	nPosCab := aScan( aCab, { |x| AllTrim(x[1]) == "P3_DATA" })
	If nPosCab > 0
		dData := aCab[nPosCab][2]
	Else
		Help(" ",1,"OBRIGAT")
		lMsErroAuto := .T.
		Return
	EndIf	
	GetAdsLckRec() // Inicializa Max_Locs do RHLIB
Else
	dData := oCalend:dDiaAtu
	If cPaisLoc == "RUS"
		// If chosen date it belongs to weekend, Type of Day suggest 
		// automatically option 3=Weekend
		If Alltrim(Upper(Cdow(dData))) == "SATURDAY" .Or. Alltrim(Upper(Cdow(dData))) == "SUNDAY"
			cTpDay := "3" // 3=Weekend
EndIf
	EndIf
EndIf

dbSelectArea("SP3")
SP3->( dbSetOrder(01) )
SP3->( dbSeek(cFilSP3+Dtos(dData),.T.) )

Begin Sequence
     
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Obtem Exclusividade no Registro                             Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF !lP020Auto .AND. !Pona020Locks( 3, "SP3", {}, { xFilial( "SP3" ) + Dtos( dData ) } )
	   Break
    EndIF

	RstfFeriado()
	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Verifica se Dia eh Feriado e Inicializa aStaticFeriado      Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	IF ( fFeriado(cFilSP3 , @dData ) ) // Alteracao ou Delecao 
		lInclusao	:= .F.                 
		cDescricao	:= SP3->P3_DESC
		cTpExt		:= SP3->P3_TPEXT
		cTpExtN		:= SP3->P3_TPEXTN
		cFerFix		:= SP3->P3_FIXO
		cSvTpFix	:= cFerFix
		If cPaisLoc == "RUS"
			cTpDay		:= SP3->P3_TPDAY
		EndIf
		If !lP020Auto
			oCalend:AddRestri(Day(dData),CLR_HRED,CLR_WHITE)
		EndIf
    Else
    	If !lP020Auto
    		dData := oCalend:dDiaAtu
    	EndIf
		lInclusao  := .T.
		cDescricao := Space( TamSx3( "P3_DESC   " )[1] )
		If cPaisLoc <> "RUS"
			cTpExt     := "4"	//Horas Extras Feriado
			cTpExtN    := "8"	//Horas Extras Feriado Noturna
		EndIf
		cFerFix	   := "N"	//Feriado Fixo ("S"im , "N"ao)
		If !lP020Auto
			oCalend:DelRestri(Day(dData))
		EndIf               
	EndIF
			  		
	IF ( lInclusao )
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Obtem Exclusividade no Registro                             Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	   IF !lP020Auto .AND. !Pona020Locks( 3 , "SP3" , NIL , { xFilial( "SP3" ) + Dtos( dData ) } )
		   Break
       EndIF
	Else    
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Obtem Exclusividade no Registro                             Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	   IF !lP020Auto .AND. !Pona020Locks( 4 , "SP3" , { SP3->( Recno() ) } , { xFilial( "SP3") + Dtos( dData ) } )
		   Break
       EndIF
	EndIF

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Destroi __aStaticFeriado                                    Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	RstfFeriado()
	
	/*/
	здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Monta a entrada de dados do Arquivo                          Ё
	юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	nOpca := 0
	
	dbSelectArea('SX3')
	SX3->( dbSetOrder( 01 ) )
	SX3->( dbSeek('SP3' , .F. ) )
	While SX3->( !Eof() .and. X3_ARQUIVO == 'SP3' )
		IF fContemStr( X3_CAMPO , 'P3_DESC' , .T. ) 
			cDesc     := x3Titulo()
		ElseIF fContemStr( X3_CAMPO , 'P3_TPEXT' , .T. ) 
			cTpNormal := x3Titulo()
		ElseIF fContemStr( X3_CAMPO , 'P3_TPEXTN' , .T. )
			cTpNoturn := x3Titulo()
		ElseIF fContemStr( X3_CAMPO , 'P3_DATA' , .T. )
			cData     := x3Titulo()
		ElseIF fContemStr( X3_CAMPO , 'P3_FIXO' , .T. )
			cTpFixo	  := x3Titulo()
		ElseIF fContemStr( X3_CAMPO , 'P3_TPDAY' , .T. )
			cDTpDay	:= x3Titulo()
		EndIF
		SX3->( dbSkip() )
	EndDo
	
	SetCursor(1)
	
	dbSelectArea("SP3") 
	
	//Execauto
	If lP020Auto		
		nPosCab := aScan( aCab, { |x| AllTrim(x[1]) == "P3_DESC" })
		If nPosCab > 0 
			cDescricao := Transform(aCab[nPosCab][2],PesqPict("SP3","P3_DESC"))
			
			If Empty( cDescricao )
				Help(" ",1,"OBRIGAT")
				lMsErroAuto := .T.
			EndIf
		
		ElseIf nOpcAuto != 5
			Help(" ",1,"OBRIGAT")
			lMsErroAuto := .T.
		EndIf
											
		nPosCab := aScan( aCab, { |x| AllTrim(x[1]) == "P3_TPEXT" })
		If nPosCab > 0			
			cTpExt := aCab[nPosCab][2]
		EndIf		
				
		nPosCab := aScan( aCab, { |x| AllTrim(x[1]) == "P3_TPEXTN" })
		If nPosCab > 0
			cTpExtN := aCab[nPosCab][2]
		EndIf		
				
		nPosCab := aScan( aCab, { |x| AllTrim(x[1]) == "P3_FIXO" })
		If nPosCab > 0
			cFerFix := aCab[nPosCab][2]
		ElseIf nOpcAuto != 5
			Help(" ",1,"OBRIGAT")
			lMsErroAuto := .T.
		EndIf

		If nOpcAuto != 5 .AND. !fTipoExtra( cTpExt ) .OR. !fTipoExtra( cTpExtN )
			Help(" ",1,"P020HREXTR") //Tipo de Hora Extra InvАlido#Confira o tipo da Hora Extra Normal e da Hora Extra Noturna.
			lMsErroAuto := .T.
		EndIf
		
		aAreaAuto := SP3->(GetArea())
		SP3->(DbSetOrder(1))
		
		If nOpcAuto == 3 .AND. SP3->(DbSeek(XFilial("SP3")+DTOS(dData)))
			Help(" ",1,"JAGRAVADO")
			lMsErroAuto := .T.
		EndIf
		
		RestArea(aAreaAuto)
		
		If !lMsErroAuto
			If nOpcAuto == 3 .OR. nOpcAuto == 4
				nOpcA := 1
			Else
				nOpcA := 8
			EndIf
		EndIf

	Else
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta as Dimensoes dos Objetos         					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdvSize		:= MsAdvSize( , .T., 390)
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 15 , 15 }
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
		aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
		
	
		//Divisao em colunas Linha 2-Para centralizacao do calendАrio
		aAdv1Size		:= aClone(aObjSize[2])
		aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//Coluna Esquerda	
		aAdd( aObj1Coords , { 040 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj1Coords , { 005 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj1Coords , { 150 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//Coluna Direita
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )   
	
		
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	 
		DEFINE MSDIALOG oDlg2 TITLE OemToAnsi( STR0015 ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd // "Calendario - Feriados"
		
			bSet15	:= {|| nOpcA := 1 , oDlg2:End()}
			bSet24	:= {|| oDlg2:End()}
				
			Aadd( aButtons, {, {|| nOpcA := 8, oDlg2:End()}, OemToAnsi( STR0047 ), OemToAnsi( STR0047 ) , {|| .T.}} )
	
			@ aObjSize[2,1],aObj1Size[2,2] SAY OemToAnsi(cData)					  	SIZE 100,10 OF oDlg2 PIXEL FONT oFont // "Data: "  
		    @ aObjSize[2,1],aObj1Size[4,2]	MSGET Dtoc(dData)				  	  	  	SIZE 150,10 OF oDlg2 PIXEL FONT oFont WHEN .F. COLOR  CLR_HRED
		
			@ aObjSize[3,1],aObj1Size[2,2] SAY OemToAnsi(cDesc )				  	  	SIZE 100,10 OF oDlg2 PIXEL FONT oFont// "Descri┤└o: "
			@ aObjSize[3,1],aObj1Size[4,2] MSGET oGet VAR cDescricao		  		  	SIZE 150,10 OF oDlg2 PIXEL FONT oFont PICTURE PesqPict("SP3","P3_DESC")  VALID !empty(cDescricao)
		   
		If cPaisLoc $ "RUS"
			@ aObjSize[4,1],aObj1Size[2,2]  SAY OemToAnsi(cDTpDay)			  			SIZE 100,10 OF oDlg2 PIXEL FONT oFont // "Type of Day"
		    @ aObjSize[4,1],aObj1Size[4,2]	COMBOBOX oGet VAR cTpDay ITEMS aTpDay   	SIZE 150,10 OF oDlg2 PIXEL FONT oFont VALID Pn020VlDay(cTpDay,@cFerFix) 
		   
			@ aObjSize[5,1],aObj1Size[2,2]	SAY OemToAnsi(cTpFixo)  			  	  	SIZE 100,10 OF oDlg2 PIXEL FONT oFont // "Fixed Holiday"
		    @ aObjSize[5,1],aObj1Size[4,2]  COMBOBOX oGet VAR cFerFix ITEMS aFixo 		SIZE 150,10 OF oDlg2 PIXEL FONT oFont WHEN If(cTpDay == "1",.F.,.T.)  
		Else   
			@ aObjSize[4,1],aObj1Size[2,2] SAY OemToAnsi(cTpNormal)				  	SIZE 100,10 OF oDlg2 PIXEL FONT oFont // "Tp.HE.Nor."
		    @ aObjSize[4,1],aObj1Size[4,2]	COMBOBOX oGet VAR cTpExt ITEMS aNormal   	SIZE 150,10 OF oDlg2 PIXEL FONT oFont VALID ( fTipoExtra( cTpExt ) .or. Empty(cTpExt) )
		   
			@ aObjSize[5,1],aObj1Size[2,2]	SAY OemToAnsi(cTpNoturn)  			  	  	SIZE 100,10 OF oDlg2 PIXEL FONT oFont // "Tp.HE.Not."
		    @ aObjSize[5,1],aObj1Size[4,2] COMBOBOX oGet VAR cTpExtN ITEMS aNoturna 	SIZE 150,10 OF oDlg2 PIXEL FONT oFont VALID ( fTipoExtra( cTpExtN ) .or. Empty(cTpExtN) )
		    
			@ aObjSize[6,1],aObj1Size[2,2]	SAY OemToAnsi(cTpFixo)  			 	  	SIZE 100,10 OF oDlg2 PIXEL FONT oFont // "Feriado Fixo"
		    @ aObjSize[6,1],aObj1Size[4,2] COMBOBOX oGet VAR cFerFix ITEMS aFixo	  	SIZE 150,10 OF oDlg2 PIXEL FONT oFont
		EndIf

		ACTIVATE MSDIALOG oDlg2 ON INIT	EnchoiceBar( oDlg2 , bSet15 , bSet24, , aButtons ) CENTERED          
	EndIf		

	dbSelectArea("SP3")
	
	Begin Transaction
		IF ( cFerFix == "N" .and. cSvTpFix == "S" )
			lInclusao := !( SP3->P3_DATA == dData ) .AND. !( dbSeek(cFilSP3 + DTOS(dData)) )
		ElseIF ( cFerFix == "S" .and. cSvTpFix == "N" )
			nLastRec := SP3->( Recno() )
			SP3->( dbSetOrder( 02 ) )
			IF SP3->( P3_DATA == dData .and. dbSeek( xFilial("SP3")+MesDia(dData)+"S" ,.F. ) )
				nOpcA := 8
	 		EndIF
	 		SP3->( dbGoto( nLastRec ) )
	 	Else
	 		lInclusao	:=	 !(fFeriado(cFilSP3 , @dData ))	 			
		EndIF

		//-- Inicializa a integracao via WebServices TSA
		If lTSREP
			oObjREP := PTSREPOBJ():New()	
		EndIF

		IF nOpcA = 1 .and. !Empty(cDescricao)
			lLock := SP3->( RecLock( "SP3" , lInclusao ) )
			IF ( lLock )
				SP3->P3_FILIAL := cFilSP3
				SP3->P3_DATA   := dData
				SP3->P3_DESC   := cDescricao
				SP3->P3_TPEXT  := cTpExt
				SP3->P3_TPEXTN := cTpExtN
				SP3->P3_FIXO   := cFerFix
				SP3->P3_MESDIA := IF( cFerFix $ "sS" , MesDia( dData ) , cP3MesDia )
				If cPaisLoc == "RUS"
					SP3->P3_TPDAY   := cTpDay
				EndIf
				SP3->( MsUnlock() )
				
				// Chama EAI para disparar integraГЦo
				If lIntegDef
					Inclui := lInclusao
					Altera := !lInclusao
					FwIntegdef("PONA020")
				EndIf
				/*/
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Ponto de Entrada para gravacao dos dados do calendario na SX5Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				IF ( lPntGrv )
					ExecBlock("PNA020GRV",.F.,.F.,{ cFilSP3, dData, cDescricao, If(lInclusao,1,2) } )
				EndIF
				If !lP020Auto
					oCalend:AddRestri(Day(SP3->P3_DATA),CLR_HRED,CLR_WHITE)
				EndIf  

			   	If lTSREP
					/*/
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Executa o WebServices TSA - Dias nao trabalhados             Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					If oObjREP:WSDayNotWorked( If(lInclusao,1,2) )
				
						/*/
						здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						Ё Grava o Log do controle de exportacao WebServices TSA        Ё
						юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
						oObjRep:WSUpdRHExp( "SP3" )
				
		            Endif
				Endif	

			EndIF	
		ElseIF nOpcA = 8 // Exclusao ou Alteracao
			lLock := SP3->( RecLock( "SP3" , .F. , .T. ) )
			IF ( lLock )
				If !lP020Auto
					oCalend:DelRestri(Day(SP3->P3_DATA))
				EndIf
				IF !( SP3->( FkDelete( @cMsgErr ) ) )
					RollBackDelTran( cMsgErr )
				EndIF	
				SP3->( MsUnlock() )
				
				If lIntegDef
					Inclui := .F.
					Altera := .F.
					FwIntegdef("PONA020")
				EndIf
				/*/
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Ponto de Entrada para gravacao dos dados do calendario na SX5Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
				IF ( lPntGrv )
					ExecBlock("PNA020GRV",.F.,.F.,{ cFilSP3, dData, cDescricao, 3 } )
				EndIF		

			   	If lTSREP
					oObjREP:WSDayNotWorked( 3 )
				Endif	

			EndIF
		EndIF
	End Transaction

End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Libera Retgistros Locados		                               Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
If !lP020Auto
	FreeLocks( "SP3" , NIL , .T. )
EndIf

RestKeys(aKeys,.T.)
RestArea( aAreaSP3 )
RestArea( aAreaSX3 )
RestArea( aArea )

Return( .T. )

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    ЁPona020Locks Ё Autor Ё Mauricio MR          Ё Data Ё16/03/2004Ё╠╠
╠╠цддддддддддедддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Acesso Exclusivo ao Dia                                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё PONA020                                                    	Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Static Function Pona020Locks( nOpc , cAlias, aRecnos , aKeysCode )

Local lLocks	:= .T.

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁSe nao For Visualizacao             	 					   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
IF ( nOpc <> 2 ) 
	lLocks := WhileNoLock( cAlias , aRecnos , aKeysCode , 0 , 1 , .T. , NIL ) 
EndIF

Return( lLocks )

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁSelecFil     Ё Autor ЁMauricio MR		   Ё Data Ё07/03/2005Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁSeleciona Filiais											 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPona020	                                                     Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

Static Function fCopiaFeriado(	cAliasOpc		,; //	Alias do temporario para selecao de filiais
								cAliasTit		,; //	Alias do temporario com dados da filial origem do feriado
								cMark			,; //	Marca do MarkBrowse
								aBrowseFields	,; //	Campos a serem mostrados no MarkBrowse	
								cFilSP3			,; //	Filial do SP3
								oCalend			;  // 	Objeto Calendario
							 )    
Local aSP3Area			:= SP3->(GetArea())							 

Local aSvKeys			:= GetKeys()
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {}
Local aObjSize			:= {}

Local aAdv1Size			:= {}
Local aInfo1AdvSize		:= {}
Local aObj1Coords		:= {}
Local aObj1Size			:= {}

Local aAdv11Size		:= {}
Local aInfo11AdvSize	:= {}
Local aObj11Coords		:= {}
Local aObj11Size		:= {}

Local aAdv2Size			:= {}
Local aInfo2AdvSize		:= {}
Local aObj2Coords		:= {}
Local aObj2Size			:= {}

Local aAdv3Size			:= {}
Local aInfo3AdvSize		:= {}
Local aObj3Coords		:= {}
Local aObj3Size			:= {}



Local aButtons			:= {}  
                                  
Local bSet15 			:= { || NIL }
Local bSet24			:= { || NIL }
Local bInitDlg			:= { || NIL } 
Local bLDblClick		:= { || RhMkMrk( cAliasOpc , .F., .F. , cCpoCtrl, cMark ),oDlg:Refresh() }
Local bAllMark			:= { || RhMkAll( cAliasOpc , .F., .T. , cCpoCtrl, cMark ),oDlg:Refresh() } 
Local bAllUnMark		:= { || RhMkAll( cAliasOpc , .T., .T. , cCpoCtrl, cMark ),oDlg:Refresh() }

Local aTitCpo			:= {}
Local aMsSlt1Coords		:= {}
Local aMsSlt2Coords		:= {}

Local cAlias 			:= Alias()

Local cCpoCtrl			:= 'MARK'   
Local cMsg				:= ""
Local lInverte			:= .F.   
Local nOpca				:= 1  

Local oDlg
Local oFontRed  
Local oGroup
Local oMsSelect  
Local oMsFilial    

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Inicializa __aStaticFeriado                                 Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RstfFeriado()

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Certifica que Browse estА toda desmarcada                    Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RstCpy(cAliasOpc,cCpoCtrl,cMark)

Begin Sequence
    
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁPosiciona no Feriado da Filial Corrente		       	   	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		 SP3->(fFeriado(cFilSP3 , oCalend:dDiaAtu ))
		 
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁDefine a Tecla de Atalho para Marcar Todos <F9>       	   	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bMarkAll	:= { || CursorWait() ,;
							Eval(bAllMark),;
							CursorArrow()}

		aAdd( aButtons ,	{;
								"CHECKED"							,;
		       					bMarkAll							,;
		    					OemToAnsi( STR0043 )				,;			//"Marca Todos"
		    					OemToAnsi( STR0043 )				 ;			//"Mc.Todos"
		       				};
			)

		SetKey( VK_F6 , bMarkAll )		



		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁDefine a Tecla de Atalho para Desmarcar Todos <F07>   	   	   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bUnMarkAll	:= { || CursorWait() ,;
							Eval(bAllUnMark),;		
							CursorArrow()}
		
		aAdd( aButtons ,	{;
								"UNCHECKED"							,;
		       					bUnMarkAll							,;
		    					OemToAnsi(STR0045)				,;		//"Inverte...<F7>"
		    					OemToAnsi(STR0045) } )
			
		SetKey( VK_F7 , bUnMarkAll )
	  	  	
	   	/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define os Blocos para as Teclas <CTRL-O>					   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet15 	:= { ||  RestKeys( aSvKeys , .T. ), aFil		:={}  		,;
						        if (ReplicaFeriado(oCalend:dDiaAtu,cAliasOpc),;
						 		oDlg:End()									,;
						 		MsgAlert(STR0042)) 							; //"Nenhuma filial selecionada"
					}
		
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Define os Blocos para as Teclas <CTRL-X>     	   			   Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		bSet24	:= { ||  RestKeys( aSvKeys , .T. ) ,oDlg:End() }

		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta as Dimensoes dos Janela                                Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		aAdvSize	:= MsAdvSize()
		aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
		aAdd( aObjCoords , { 000 , 059 , .T. , .F. } )		//01 Form
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } ) 	//02 MsSelect
		aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )		//03 MsSelect
		aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
		
		//Divisao em 5 linhas de 1-Form1 
		aAdv1Size		:= aClone(aObjSize[1])
		aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 6 , 6 }
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//1-Linha - para centralizar	
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//2-Linha 
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//3-Linha 
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//4-Linha 
		aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//5-Linha - para centralizar
		aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords )   
		
		//Divisao em colunas Linha 1-Form1 - em 9 colunas		
		aAdv11Size		:= aClone(aObj1Size[1])
		aInfo11AdvSize	:= { aAdv11Size[2] , aAdv11Size[1] , aAdv11Size[4] , aAdv11Size[3] , 1 , 1 }
		aAdd( aObj11Coords , { 000 , 000 , .T. , .T. } )			//Coluna Esquerda	
		aAdd( aObj11Coords , { 040 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj11Coords , { 005 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj11Coords , { 150 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj11Coords , { 000 , 000 , .T. , .T. } )			//Separador Central
		aAdd( aObj11Coords , { 040 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj11Coords , { 005 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj11Coords , { 150 , 000 , .F. , .T. } )			//Coluna Central
		aAdd( aObj11Coords , { 000 , 000 , .T. , .T. } )			//Separador Central
		aObj11Size		:= MsObjSize( aInfo11AdvSize , aObj11Coords,,.T. )   

        
		//Group 2 
		aAdv2Size		:= aClone(aObjSize[2])
		aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 10 }
		aAdd( aObj2Coords , { 000 , 000 , .T. , .T.  } )			//Coluna Esquerda	
		aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords )   

		//Group 3 
		aAdv3Size		:= aClone(aObjSize[3])
		aInfo3AdvSize	:= { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 10 }
		aAdd( aObj3Coords , { 000 , 000 , .T. , .T.  } )			//Coluna Esquerda	
		aObj3Size		:= MsObjSize( aInfo3AdvSize , aObj3Coords )   

						
		aEval(aBrowseFields,{|acpos| Iif( acpos[1] <> cCpoCtrl, AADD(aTitCpo, acpos ), Nil ) } )
															
		/*/
		здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		Ё Monta Dialogo 						                       Ё
		юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
		DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0015 ) FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] PIXEL OF oMainWnd // "Calendario - Feriados"
					
			DEFINE FONT oFontRed NAME "Verdana" SIZE 0,-9 BOLD  
						
			/*/
			здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			Ё Informacoes sobre o feriado da filial corrente			   Ё
			юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
			fShowFer(oDlg, oCalend, aObj1Size, aObj11Size, aObjSize)
			
			@ aObjSize[2,1], aObjSize[2,2] GROUP oGroup TO aObjSize[2,3], aObjSize[2,4]	LABEL OemToAnsi(STR0032) OF oDlg PIXEL COLOR CLR_HRED // "COPIAR DA FILIAL CORRENTE..."
		   			
			oMsFilial := MsSelect():New(;
											cAliasTit		    ,;	//01-Alias do Arquivo com a Filial Corrente
											Nil        			,;	//02-Campo para controle do mark
						 					Nil					,;	//03-Condicao para o Mark
											aTitCpo				,;	//04-Array com os Campos para o Browse - aTitCpo
											.F.					,;	//05-lInverte
											Nil					,;	//06-Conteudo a Ser Gravado no campo de controle do Mark
											aObj2Size[1]		,;	//07-Coordenadas do Objeto
											Nil					,;  //08-?
											Nil					,;	//09-?	
											oDlg			 	;	//10-Objeto Dialog
									)
						
			
			@ aObjSize[3,1], aObjSize[3,2] GROUP oGroup TO aObjSize[3,3], aObjSize[3,4]	LABEL OemToAnsi(STR0033) OF oDlg PIXEL COLOR CLR_HRED // "PARA AS FILIAIS SELECIONADAS ABAIXO:..."
						
			(cAliasOpc)->(Dbseek(cFilSP3))
		   
		   	oMsSelect := MsSelect():New(;
											cAliasOpc		,;	//Alias	do Arquivo de Filtro
											cCpoCtrl        ,;	//Campo para controle do mark
						 					Nil			    ,;	//Condicao para o Mark
											aBrowseFields	,;	//Array com os Campos para o Browse
											.F.				,;	//lInverte
											cMark			,;	//Conteudo a Ser Gravado no campo de controle do Mark
											aObj3Size[1]	,;	//Coordenadas do Objeto
											NIL				,;  //?
											NIL				,;	//?	
											oDlg			 ;	//Objeto Dialog
									)
			
			oMsSelect:oBrowse:lCanAllMark	:= .T.
			oMsSelect:oBrowse:lHasMark	 	:= .T.  
		   	oMsSelect:bMark	 				:= bLDblClick     
			oMsSelect:oBrowse:bAllMark      := bMarkAll 
						
		ACTIVATE MSDIALOG oDlg ON INIT (enchoicebar( oDlg , bSet15 , bSet24 ,, aButtons )	,;
										Eval( oMsSelect:oBrowse:bGotop ) 					,;
										oMsSelect:oBrowse:Refresh()) ;
										CENTERED
		RestKeys( aSvKeys , .T. )
		
End

/*/
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Destroi __aStaticFeriado                                    Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
RstfFeriado()

RestArea(aSP3Area)

Return   

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRhMkAll      Ё Autor ЁMauricio MR		   Ё Data Ё07/03/2005Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMarca/Desmarca todos os elementos do browse   		         Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA020                                                      Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

Static Function RhMkAll( 	cAlias		,; // Alias do temporario para selecao das filiais
							lInverte	,; // Se inverte a selecao	
							lTodos		,; // Se inverte todas as selecoes	
							cCpoCtrl	,; // Campo de Selecao
							cMark		;  // Marca da Selecao 
						)   
Local nRecno		:= (cAlias)->(Recno())

(cAlias)->( dbGotop() )

While (cAlias)->( !Eof() )  
	
	RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark)
	
	(cAlias)->( dbSkip() )
EndDo

(cAlias)->( MsGoto( nRecno ) )

        
Return

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁRhMkMrk      Ё Autor ЁMauricio MR		   Ё Data Ё07/03/2005Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMarca/Desmarca um elemento do browse   				         Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA020                                                      Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

Static Function RhMkMrk( 	cAlias		,; // Alias do temporario para selecao das filiais
							lInverte	,; // Se inverte a selecao	
							lTodos		,; // Se inverte todas as selecoes	
							cCpoCtrl	,; // Campo de Selecao
							cMark		;  // Marca da Selecao 
						) 
Local cTemp


DEFAULT cAlias		:= Alias()

If lTodos
    If lInverte
	   	If IsMark( cCpoCtrl, cMarK) 
		  cTemp:= cSpaceMarca   
		Else
	      cTemp:= cMark
		Endif   
	Else 
		cTemp:=cMark   
	Endif	
Else        
	If IsMark( cCpoCtrl, cMarK, lInverte) 
		cTemp:= If(lInverte, cSpaceMarca, cMark)   
	Else
	   cTemp:= If(lInverte, cMark, cSpaceMarca)   
	Endif   
Endif	    


//-- Alteracao Selecao
(cAlias)->(RecLock(cAlias,.F.))
	&(cAlias+'->'+cCpoCtrl) := cTemp
(cAlias)->(MsUnlock())
  
                 
Return .T.

/*/{Protheus.doc} RstCpy
Certifica que MarkBrowse estА com todos os itens desmarcados antes de inicializar
uma nova cСpia sem sair da Dialog Principal
@author raquel.andrade
@since 12/12/2019
@version 12.1.25
/*/
Static Function RstCpy(cAlias,cCpoCtrl,cMark) 
Local nRecno		:= (cAlias)->(Recno())
DEFAULT cAlias		:= Alias()
DEFAULT cCpoCtrl	:= "MARK"
DEFAULT cMark		:= "AF"


(cAlias)->( dbGotop() )

While (cAlias)->( !Eof() )  
	
	(cAlias)->(RecLock(cAlias,.F.))
	&(cAlias+'->'+cCpoCtrl) := cSpaceMarca
	(cAlias)->(MsUnlock())
	
	(cAlias)->( dbSkip() )
EndDo

(cAlias)->( MsGoto( nRecno ) )


Return 

/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁCriaArqFil   Ё Autor ЁMauricio MR		   Ё Data Ё21/12/2006Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCria Arquivo de Filiais a serem selecionadas	  	         Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA020                                                      Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

Static Function CriaArqFil(	cMarca				,; // Marca da Selecao
							aBrowseFields		,; // Campos que serao mostrados no MarkBrowse
							cAliasTmp1			,; // Alias do arquivo Temporario com as Filiais para selecao
							cAliasTmp2			,; // Alias do arquivo Temporario com a Filial corrente do feriado
							cFilSP3				;  // Filial do SP3
						  )
Local aSM0Area		:= SM0->(GetArea()) 
Local aArea			:= GetArea()
Local aFields		:= 	{} 
Local aTitulosCpos 	:=	{}

Local cArq			:= ""		
Local cIndCond
Local cMsg			:= OemToANSI(STR0031) //'Selecionando Registros...'
Local cTitulo                            
Local cDataFile		
Local cExt			:= GetDbExtension()
Local cRotina		:= 'PONA020'  
Local cSpaceMarca	:= 	Space(Len(cMarca))
Local lRet			:= .T.   
Local nLoop		
Local nOriginal		
Local nPosCpo
Local nTotLoop	
Local aLstIndices := {}

If cPaisLoc == "RUS"
	aTitulosCpos := { 		{ "M0_FILIAL"	, OemToAnsi( STR0049 ) 		} ,; // Filial
							{ "M0_NOME"		, OemToAnsi( STR0050 )  	} ,; // Nome
							{ "M0_CIDENT"	, OemToAnsi( STR0051 )  	} ,; // City 
							{ "M0_ENDENT"	, OemToAnsi( STR0053 )  	} ,; // Address
							{ "M0_CEPENT"	, OemToAnsi( STR0054 )	  	} ; // ZIP Code
						}
Else
	aTitulosCpos := { 		{ "M0_FILIAL"	, OemToAnsi( STR0049 ) 		} ,; // Filial
							{ "M0_NOME"		, OemToAnsi( STR0050 )  	} ,; // Nome
							{ "M0_CIDENT"	, OemToAnsi( STR0051 )  	} ,; // City 
							{ "M0_ESTENT"	, OemToAnsi( STR0052 )  	} ,; // State
							{ "M0_ENDENT"	, OemToAnsi( STR0053 )  	} ,; // Address
							{ "M0_CEPENT"	, OemToAnsi( STR0054 )	  	} ; // ZIP Code
						}
EndIf

If !Empty(Select(cAliasTmp1))
	dbSelectArea(cAliasTmp1)
	dbCloseArea()
	
	If oTmp1Tab <> Nil
	    oTmp1Tab:Delete()
	    Freeobj(oTmp1Tab)
	EndIf
	
Endif

//-- Adiciona Campo de Selecao para o MarkBorwse
AADD(aFields		,{'MARK'	,	'C'		,2	,	0 	})
AADD(aBrowseFields	,{'MARK'	, 	cRotina	, "ok"		}) //OK
aSM0Estruct:= SM0->(DbStruct())

//-- Adiciona Demais Campos do Arquivo Temporario
nTotLoop	:= Len(aSM0Estruct)  

For nLoop:=1 To nTotLoop
	AADD(aFields,{	aSM0Estruct[nLoop,1]    ,;
               		aSM0Estruct[nLoop,2]  	,;
					Iif(ALLTRIM(aSM0Estruct[nLoop,1])=="M0_CODFIL",FWSizeFilial(), aSM0Estruct[nLoop,3])  	,;
					aSM0Estruct[nLoop,4]  	,;	  
				  };
	      )  
	      
   IF (nPos:=Ascan(aTitulosCpos, {|cCpo| cCpo[1] ==Alltrim(Upper(aSM0Estruct[nLoop,1] )) 	}) ) > 0
		cTitulo:= aTitulosCpos[nPos,2]		      
   Else     
   		cTitulo:=StrTran(aSM0Estruct[nLoop,1],'SM0_',"") 
   		Loop
   Endif 	 
         
   AADD(aBrowseFields,{		aSM0Estruct[nLoop,1]  , cRotina, cTitulo } )
Next nLoop

 
//Abre o Arquivo Temporario  
AAdd(aLstIndices, {"M0_CODFIL"} )

oTmp1Tab := RhCriaTrab(cAliasTmp1, aFields, aLstIndices)	


//Abre o Arquivo Temporario
oTmp2Tab := RhCriaTrab(cAliasTmp2, aFields, Nil)	

IF ( lRet := ( Select( cAliasTmp1 ) > 0.00 ) )
	nTotLoop	:= Len(aFields)  
	
	//-- Transfere as Filiais da empresa para o array de opcoes               
	dbSelectArea("SM0")
	SM0->(dbSeek(cEmpAnt))

	While SM0->(!Eof() .and. SM0->M0_CODIGO == cEmpAnt )
        
		//-- Se a filial eh valida para o usuario
		If  !( FWGETCODFILIAL $ fValidFil() )
	    	SM0->( dbSkip() )
			Loop
		Endif
        
        If FWGETCODFILIAL == cFilSP3  
           cArq:= cAliasTmp2
        Else
           cArq:= cAliasTmp1
        Endif   
       
    	(cArq)->(Reclock(cArq,.T.) )  
		
		//-- TransferE o registro para o registro com a estrutura alterada
		For nLoop:=1 to nTotLoop               
	
	   	    //-- Trata o campo de 'Selecao' de Filial
	   	    If aFields[nLoop,1] == 'MARK'
		   	   (cArq)->MARK 		:= cSpaceMarca
			Else
				//-- Transfere o conteudo do campo original para o da nova estrutura do arquivo temporario    
				(cArq)->(FieldPut(nLoop, SM0->( &(aFields[nLoop,1]) )) )
			EndIf
					
		Next nLoop    
		
		(cArq)->(MsUnlock())
	    (cArq)->(FkCommit())
    	SM0->( dbSkip() )
	 Enddo   

	(cAliasTmp1)->( dbGotop() )
	(cAliasTmp2)->( dbGotop() )
EndIF	
RestArea(aSM0Area)
RestArea(aArea) 
Return( lRet )
               

/*
зддддддддддбддддддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁTrataArq()		Ё Autor ЁMauricio MR           Ё Data Ё22/12/2006Ё
цддддддддддеддддддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁAtualiza o estado de selecao das filiais						 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL																 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                	      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁPONA020     													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
Static Function TrataArq(	cFil			,; // Filial do SM0
							lSP3Exclusivo	,; // Se o SP3 eh excluisivo
							cAliasTmp1		,; // Alias do temporario do arquivo de selecao de filiais
							nRecno			,; // Recno da Filial do SM0
							lDeleta			;  // Indica se a marca deve ser retirada da filial selecionada
						)    
Local cConteudo := ""
Local lFound	:= .F.

DEFAULT lDeleta	:= .F. 

IF lSP3Exclusivo
	cConteudo := IF(lDeleta, cSpaceMarca, cMark)

	If !Empty(nRecno)
	    lFound:= .T.	
	Else
	    lFound:= (cAliasTmp1)->(Dbseek(cFil))
	Endif

	IF lFound
		(cAliasTmp1)->(RecLock(cAliasTmp1,.F.))
		(cAliasTmp1)->MARK := cConteudo
		(cAliasTmp1)->(MsUnlock())
	EndIF
Endif
Return

/*
зддддддддддбддддддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfProgAtual()	Ё Autor ЁMauricio MR           Ё Data Ё22/12/2006Ё
цддддддддддеддддддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁControla recursividade de chamada de funcao via tecla programada Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL																 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                	      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁSIGAPON     													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
Static function fProgAtual()
Local lRet			:= .T.
Local cProcName3	:= Upper( AllTrim( ProcName( 3 ) ) )
Local cProcName4	:= Upper( AllTrim( ProcName( 4 ) ) )
Local cProcName5	:= Upper( AllTrim( ProcName( 5 ) ) )

lRet:=( "PONA020" $ ( cProcName3 + cProcName4 + cProcName5 ) )

Return (lRet) 

/*
зддддддддддбддддддддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfChamaTelaCopia() Ё Autor ЁMauricio MR         Ё Data Ё22/12/2006Ё
цддддддддддеддддддддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁControla a chamada da tela para copia dos dados do feriado		 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL																 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                	      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁSIGAPON     													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
Static Function fChamaTelaCopia(	cFilSP3			,; // Filial do SP3
									oCalend			,; // Objeto Calendario
									lSP3Exclusivo	,; // Indica se o SP3 eh exclusivo
									cAliasTmp1		,; //	Alias do temporario para selecao de filiais
									cAliasTmp2		,; //	Alias do temporario com dados da filial origem do feriado
									cMark			,; //	Marca do MarkBrowse
									aBrowseFields	; //	Campos a serem mostrados no MarkBrowse	
							   ) 

Local aKeys		:= GetKeys() 									
Local lRet		:= 	.F.
Local aSP3Area	:=	SP3->(GetArea())  

//-- Se existir feriado na Data (ou no mes/dia para feriados fixos)
IF  SP3->(fFeriado(cFilSP3 , oCalend:dDiaAtu ))
	//-- Garante o retorno a posicao originial
	SP3->(MsGoto(aSP3Area[3]))   
	//-- Obtem a relacao de Filiais para selecao
    IF( lSP3Exclusivo, fFilFerDia(oCalend, cAliasTmp1, lSP3Exclusivo), NIL )
	//-- Abre um dialogo para escolha e replicacao dos dados do feriado
	fCopiaFeriado(cAliasTmp1, cAliasTmp2, cMark, aBrowseFields, cFilSP3, oCalend)   

	lRet	:= .T.
Else
	MsgAlert(STR0035)  //"O dia nao eh feriado"
EndIF

//-- Garante o retorno a posicao originial
SP3->(MsGoto(aSP3Area[3]))  

RestKeys(aKeys,.T.)

Return (lRet)


/*
зддддддддддбддддддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfShowFer()		Ё Autor ЁMauricio MR           Ё Data Ё26/12/2006Ё
цддддддддддеддддддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMostra as informacoes do feriado da filial corrente.			 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>										 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL																 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                	      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁSIGAPON     													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/ 
Static Function fShowFer(		oDlg2		,; // Dialogo que contera a replicacao do feriado
								oCalend		,;  // Objeto Calendario          
								aObjSizeL	,;	//Coordenadas da dialog Linhas
								aObjSizeC	,;	//Coordenadas da dialog Colunas
								aObjSizeM 	;	//Moldura do group
						) 
Local aKeys:=GetKeys() 
Local aNormal		:= {}
Local aNoturna		:= {}
Local aFixo	 		:= {}

Local cDesc     	:= ""
Local cData			:= ""
Local cTpNormal 	:= ""
Local cTpNoturn 	:= ""
Local cTpFixo   	:= ""   
Local cDTpDay		:= ""
Local dData			:= oCalend:dDiaAtu 

Local cDescricao
Local cTpExt
Local cTpExtN
Local cFerFix
Local cTpDay

Local oFont1   
Local oFont2     
Local oGroup

DEFINE FONT oFont1 NAME "Verdana" SIZE 0,-10 BOLD
DEFINE FONT oFont2 NAME "Verdana" SIZE 0,-11 BOLD
                                
aNormal  	:= Sx3Box2Arr( "P3_TPEXT"  )
aNoturna	:= Sx3Box2Arr( "P3_TPEXTN" )
aFixo		:= Sx3Box2Arr( "P3_FIXO"   )
If cPaisLoc == "RUS"
	aTpDay		:= Sx3Box2Arr( "P3_TPDAY"   )
EndIf

cDescricao	:= SP3->P3_DESC  

cTpExt		:= StrTran( aNormal[ Ascan(aNormal,{|x| Substr(x,1,1) == SP3->P3_TPEXT })]	, "=", "-" )
cTpExtN		:= StrTran( aNoturna[ Ascan(aNoturna,{|x|Substr(x,1,1) == SP3->P3_TPEXTN })]	, "=", "-" )
cFerFix		:= StrTran( aFixo[ Ascan(aFixo,{|x| Substr(x,1,1) == SP3->P3_FIXO })]	, "=", "-" )
If cPaisLoc == "RUS"
	cTpDay		:= StrTran( aTpDay[ Ascan(aTpDay,{|x| Substr(x,1,1) == SP3->P3_TPDAY })]	, "=", "-" )
EndIf
dbSelectArea('SX3')
SX3->( dbSetOrder( 01 ) )
SX3->( dbSeek('SP3' , .F. ) )
While SX3->( !Eof() .and. X3_ARQUIVO == 'SP3' )
	IF fContemStr( X3_CAMPO , 'P3_DESC' , .T. ) 
		cDesc     := x3Titulo()
	ElseIF fContemStr( X3_CAMPO , 'P3_TPEXT' , .T. ) 
		cTpNormal := x3Titulo()
	ElseIF fContemStr( X3_CAMPO , 'P3_TPEXTN' , .T. )
		cTpNoturn := x3Titulo()
	ElseIF fContemStr( X3_CAMPO , 'P3_DATA' , .T. )
		cData     := x3Titulo()
	ElseIF fContemStr( X3_CAMPO , 'P3_FIXO' , .T. )
		cTpFixo	  := x3Titulo()
	ElseIF fContemStr( X3_CAMPO , 'P3_TPDAY' , .T. )
		cDTpDay	  := x3Titulo()
	EndIF
	SX3->( dbSkip() )
EndDo

SetCursor(1)

dbSelectArea("SP3")

@ aObjSizeM[1,1] , aObjSizeM[1,2] GROUP oGroup TO aObjSizeM[1,3],aObjSizeM[1,4]	LABEL OemToAnsi(STR0034) OF oDlg2 PIXEL	 //DADOS DO FERIADO:

@ aObjSizeL[2,1], aObjSizeC[2,2]	SAY OemToAnsi(cData)	   	SIZE 050, 10 OF oDlg2 PIXEL FONT oFont1 // "Data: "
@ aObjSizeL[2,1], aObjSizeC[4,2]  	MSGET Dtoc(dData)		   	SIZE 050, 10 OF oDlg2 PIXEL FONT oFont1 WHEN .F. COLOR  CLR_HRED

@ aObjSizeL[3,1], aObjSizeC[2,2]	SAY OemToAnsi(cDesc )	   	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1// "Descri┤└o: "
@ aObjSizeL[3,1], aObjSizeC[4,2] 	MSGET oGet VAR cDescricao  	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 WHEN .F. PICTURE PesqPict("SP3","P3_DESC")


If cPaisLoc == "RUS"
	@ aObjSizeL[3,1], aObjSizeC[6,2]	SAY OemToAnsi(cDTpDay)	 	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 // "Type of Day"
	@ aObjSizeL[3,1], aObjSizeC[8,2] 	MSGET oGet VAR cTpDay    	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1  WHEN .F.

	@ aObjSizeL[4,1], aObjSizeC[2,2]	SAY OemToAnsi(cTpFixo)  	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 // "Feriado Fixo"
	@ aObjSizeL[4,1], aObjSizeC[4,2] 	MSGET  oGet VAR cFerFix     SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 WHEN .F.	
Else
	@ aObjSizeL[3,1], aObjSizeC[6,2]	SAY OemToAnsi(cTpFixo)   	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 // "Feriado Fixo"
	@ aObjSizeL[3,1], aObjSizeC[8,2] 	MSGET  oGet VAR cFerFix    	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1  WHEN .F.

	@ aObjSizeL[4,1], aObjSizeC[2,2]	SAY OemToAnsi(cTpNormal)  	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 // "Tp.HE.Nor."
	@ aObjSizeL[4,1], aObjSizeC[4,2] 	MSGET  oGet VAR cTpExt     	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 WHEN .F.

	@ aObjSizeL[4,1], aObjSizeC[6,2]	SAY OemToAnsi(cTpNoturn) 	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 // "Tp.HE.Not."
	@ aObjSizeL[4,1], aObjSizeC[8,2] 	MSGET  oGet VAR cTpExtN    	SIZE 100, 10 OF oDlg2 PIXEL FONT oFont1 WHEN .F.
EndIf


dbSelectArea("SP3")  
RestKeys(aKeys,.T.)
Return (Nil)	



/*/
зддддддддддбдддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁReplicaFeriado Ё Autor ЁMauricio MR		   Ё Data Ё26/12/2006Ё
цддддддддддедддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁReplica Feriado para as Filiais Selecionadas		   		 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA020                                                      Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/

Static Function ReplicaFeriado( dData 		,;  // Data do Feriado para pesquisa
								cAliasTMP	)   //Alias do markbrowse

Local aArea			:=GetArea()	 
Local aAreaSP3		:=SP3->(GetArea())	
Local aStructSP3	:= SP3->(dbStruct())
Local aCpos			:= {}  
Local lAlera		:= .F.
Local lRet			:= .F.
Local nX
Local lTSREP		:= SuperGetMv( "MV_TSREP" , NIL , .F. )
Private oObjREP		:= Nil

CursorWait() 

//-- Inicializa a integracao via WebServices TSA
If lTSREP
	oObjREP := PTSREPOBJ():New()	
EndIF
               
//--Armazena o conteudo dos campos do feriado corrente
Aeval(aStructSP3,{|x,y| SP3->(AADD(aCpos, {x[1],&(x[1])} )) } )
//-- Corre todas as filiais selecionadas e replica o feriado corrente

(cAliasTMP)->( dbGotop() )

//-- Corre Todas as Filials disponiveis
While (cAliasTMP)->( !Eof() )  

	//-- Se existir o feriado para a filial altera o registro
	//-- caso contrario, inclui o feriado
	lAltera := !PosFeriado( (cAliasTMP)->M0_CODFIL , dData )

	If !Empty( (cAliasTMP)->MARK ) 
	
		IF SP3->(RecLock("SP3",lAltera))
		    lRet	:=	.T.
			Aeval(aStructSP3,{|x,y|TransfCpos((cAliasTMP)->M0_CODFIL, y, aCpos[y,2]) })
	
			// Caso exista o campo de controla de exportacao, apaga quando for transferido
			If SP3-> ( FieldPos ("P3_RHEXP") )  > 0
				SP3->P3_RHEXP := Space(6)
			Endif
	
	       	SP3->(MsUnlock()) 
	       	SP3->(FkCommit())
	       	
	       	If lIntegDef
	       		Inclui := lAltera
	       		Altera := !lAltera
	       		FwIntegdef( "PONA020" )
	       	EndIf
	
			If lTSREP
				/*/
				здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				Ё Executa o WebServices TSA - Dias nao trabalhados             Ё
				юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
				If oObjREP:WSDayNotWorked( If(lAltera,1,2) , If(!Empty(xFilial("SP3")), { SP3->P3_FILIAL }, {} ) )
				
					/*/
					здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					Ё Grava o Log do controle de exportacao WebServices TSA        Ё
					юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
					oObjRep:WSUpdRHExp( "SP3" )
				
				Endif
			EndIF
	    EndIF
	Endif
	(cAliasTMP)->( dbSkip() )

EndDo      



CursorArrow()
   
Return(lRet) 

/*/
зддддддддддбдддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁTransfCpos 	   Ё Autor ЁMauricio MR		   Ё Data Ё27/12/2006Ё
цддддддддддедддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁTransfere o conteudo dos campos da filial corrente para as   Ё
Ё          Ёde destino.                                                  Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA020                                                      Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static function TransfCpos(	cFilDestino		,; //Filial destino
							nPosCpo			,; //Posicao do campo a ser transferido 
							uConteudo		;  //Conteudo a ser transferido
						  ) 
//-- Altera o conteudo do campo filial para a filial destino
//-- os demais campos sao transferidos para a filial destino
uConteudo := SP3->(If(  ( 'P3_FILIAL'== Upper(Alltrim(FieldName(nPosCpo) ))), cFilDestino ,uConteudo ))
 SP3->(FieldPut(nPosCpo,uConteudo))
Return(Nil)

/*/
зддддддддддбдддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPosFeriado	   Ё Autor ЁMauricio MR		   Ё Data Ё27/12/2006Ё
цддддддддддедддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁPosiciona no registro de Feriado da filial selecionada se	 Ё
Ё          Ёexistir.                                                 	 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁNIL                                                  	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁPONA020                                                      Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Static Function PosFeriado(  cFil 	,;  // Filial para pesquisa da existencia do feriado
							 dDate 	;   // Data a ser pesquisa da filial
						  )

Local aArea		:= {}
Local cMesDia	:= ""
Local cAno		:= ""
Local lFeriado	:= .F.
Local nOrderDt	:= RetOrdem( "SP3" , "P3_FILIAL+Dtos(P3_DATA)" )
Local nOrderMd	:= RetOrdem( "SP3" , "P3_FILIAL+P3_MESDIA+P3_FIXO" )

aArea := SP3->( GetArea() )
//-- Busca Feriado pela Data
SP3->( dbSetOrder( nOrderDt ) )
IF ( lFeriado :=  SP3->(DBSeek(cFil+DtoS(dDate),.F.) ))  
	SP3->( dbSetOrder( aArea[ 02 ] ) )
Else                
    //-- Busca o Feriado pelo Dia/Mes 
	SP3->( dbSetOrder( nOrderMd ) )
	cMesDia := MesDia( dDate )
	cAno	:= SubStr( AllTrim( Dtos( dDate ) ) , 1 , 4  )
	IF ( lFeriado := SP3->( DBSeek( ( cFil + cMesDia + "S" ) , .F. )  ) )
		dDate := Stod( ( cAno + cMesDia ) )
	Else
		SP3->( MsGoto( aArea[ 03 ]  )  )
	EndIF
	SP3->( dbSetOrder( aArea[ 02 ] ) )
EndIF

Return( lFeriado )

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё IntegDef    Ё Autor Ё                    Ё Data Ё 28/03/13 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё PONA020                                                    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVerMsg )

Local aRet := {}

aRet:= PONI020 ( cXml, nTypeTrans, cTypeMessage, cVerMsg )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Pn020VlDay
Validation on field screen 'Type of Day' and 'Fixed Holiday'
@author raquel.andrade
@since 20/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function Pn020VlDay(cTpDay, cFerFix)
Local lRet		:= .T.
Default cTpDay	:= ""

If cPaisLoc == "RUS"
	cVar	:=	ReadVar()
	If cVar == "CTPDAY"	
		// 1=Holiday for Type of Day, Fixed Holiday must be "S=Yes"
		cFerFix	:=	Iif(cTpDay == "1","S","N")
	EndIf
EndIf

Return lRet

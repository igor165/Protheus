#INCLUDE "PROTHEUS.CH"
#INCLUDE "RHLIBPER.CH"

/*/
зддддддддддбддддддддддддддбддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁInRhLibPerExecЁAutor ЁMauricio MR		   Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддаддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁExecutar Funcoes Dentro de RHLIBPER                          Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁInRhLibPerExec( cExecIn , aFormParam )						 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁuRet                                                 	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico 													 Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function InRhLibPerExec( cExecIn , aFormParam )
         
Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= __ExecMacro( cExecIn )
EndIF

Return( uRet )



/**********************************/
//  E  X  E  M  P  L  O             //
/**********************************/

/*/   
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁfGetPeriodo   Ё Autor Ё Equipe Advanced RHЁ Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁObtem o periodo de apontamento							    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁExemplo   ЁoPeriodo:=RHPERIODO:New()       //Criacao do Obj            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁfGetPeriodo(cFil,cMat,dDtPesq,dIniAfas,dFimAfas,cTipAfas)   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function fGetPeriodo( oPeriodo)

Local aArea 		:= GetArea()
Local lRet 			:= .T.

Begin Sequence      
   
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁObtem Informacoes do Periodo Solicitado					  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	oPeriodo:GetPer()

    
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁMostra Advertencia para Periodo Nao Encontrado				  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !oPeriodo:lFound
 		lRet		:= .F. 
		MsgInfo( OemToAnsi( oPeriodo:cMsgNotFoundPer ) )	//"PerМodo de Apontamento NЦo Encontrado."
 		Break
	Endif

	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁMostra Advertencia de Periodo Aberto para Manutencao de PerioЁ
	Ёdos Fechados.												  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 	If oPeriodo:lAberto .and. lPona180
		MsgInfo( OemToAnsi( oPeriodo:cMsgOpenedPer ) )    //"PerМodo de Apontamento Aberto. Selecione ou informe um PerМodo Fechado."
 		lRet		:= .F.
 		Break

	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁMostra Advertencia de Periodo Fechado p/ Manutencao de Perio Ё
	Ёdos Abertos.												  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//Se lpona180 for .f., somente podera ser visualizado periodos que estejam abertos (rch_dtfech vazio) 		
 	ElseIf oPeriodo:lFechado .and. !lPona180
		MsgInfo( OemToAnsi( oPeriodo:cMsgClosedPer ) )    //"PerМodo de Apontamento Fechado. Selecione ou informe um PerМodo Aberto."
		lRet		:= .F.
 		Break
 	EndIf

End Sequence


зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
ЁRecupera Valores do Periodo antes da Troca de Periodo 		  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lRet
	oPeriodo:RollBack()
Endif

RestArea( aArea )

Return( lRet )
/*/


/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁClasse    ЁRHPeriodo     Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁClasse para a criacao do Objeto Periodo						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj	:= RHPeriodo():New() 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё		ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL				Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁProgramadorЁ Data     Ё BOPS      | Motivo da Alteracao                Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁIgorFranzoiЁ10/10/2008Ё BOPS      | Passagem por Ref. para PerAponta	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
/*/

class RHPeriodo  
    data oPerAponta
	data cFilRCH
	data cProcesso
	data cRoteiro
    data cPeriodo
    data cNumPagto
    data cAno
    data cMes  
	data dDataIni
	data dDataFim
	data dDtFecha
	data lPerSel
	data lFechado
	data lAberto 
	data lFound	
	data lPGenerico 
	data lPerAponta
	data nRecno    
	data aPeriodos

	data cAntFilRCH
	data cAntProcesso
	data cAntRoteiro
  	data cAntPeriodo
    data cAntNumPagto
    data cAntAno
    data cAntMes  
	data dAntDataIni
	data dAntDataFim
	data dAntDtFecha	
	data lAntFechado
	data lAntAberto 
	data lAntFound	
	data nAntRecno
    
    data cMsgNotFoundPer
	data cMsgOpenedPer
	data cMsgClosedPer
	data cMsgPerAntOpened
	data cMsgPerNextClosed
	data cMsgPerNextNotFound
	
	method New() constructor    
	method AaDDPer(aItensPer,nPos)
	method GetPer(cFiltro)
	method PriAberto(cFiltro)	
	method PerAberto(cFiltro)  
	method PerSel(cFiltro) 
	method PerAnt(cFiltro)
	method PerUltFech(cFiltro)	
	method PerLoad()
	method RollBack() 
	 
endclass  


/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁNew           Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para instanciar o objeto Periodo						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj	:= RHPeriodo():New() 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
Method New() class RHPeriodo
	::cFilRCH		:= xFilial("RCH")
	::cProcesso		:= ""
	::cRoteiro      := "PON"
    ::cPeriodo		:= ""
    ::cNumPagto		:= ""
    ::cAno			:= ""
    ::cMes			:= ""
    ::dDataIni		:= Ctod("")
	::dDataFim		:= Ctod("")
	::dDtFecha		:= Ctod("")	
	::lPerSel		:= .F.
	::lFechado		:= .F.
	::lAberto		:= .F.		
	::lFound		:= .F.
	::lPGenerico	:= .F.
	::lPerAponta	:= .F.
	::nRecno		:= 0			
	
	::cAntFilRCH	:= ""
	::cAntProcesso	:= ""
	::cAntRoteiro   := "PON"
	::cAntPeriodo	:= ""
    ::cAntNumPagto	:= ""
    ::cAntAno		:= ""
    ::cAntMes		:= ""
    ::dAntDataIni	:= Ctod("")
	::dAntDataFim	:= Ctod("")
	::dAntDtFecha	:= Ctod("")		
	::lAntFechado	:= .F.
	::lAntAberto	:= .F.		
	::lAntFound		:= .F.
	::nAntRecno     := 0  
	
	::cMsgNotFoundPer	   := STR0001  //"PerМodo de Apontamento NЦo Encontrado."
	::cMsgOpenedPer		   := STR0002  //"PerМodo de Apontamento Aberto. Selecione ou informe um PerМodo Fechado."
	::cMsgClosedPer		   := STR0003  //"PerМodo de Apontamento Fechado. Selecione ou informe um PerМodo Aberto."  
	::cMsgPerAntOpened     := STR0004  //"PerМodo de Apontamento anterior nЦo foi fechado."
	::cMsgPerNextClosed    := STR0005  //"PrСximo PerМodo de Apontamento estА fechado."
	::cMsgPerNextNotFound  := STR0006  //"PrСximo PerМodo de Apontamento nЦo foi encontrado. Cadastre-o para continuar."
    
    ::aPeriodos 	:= {}                    
    
    ::oPerAponta	:= PeriodoAp():New()		   	
Return(Nil)	

/*/
зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁClass     ЁPeriodoAp   Ё Autor ЁMauricio MR		   Ё Data Ё02/07/2008Ё
цддддддддддеддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁClasse com parametros da funcao PerAponta()					 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj := PeriodoAp():New()									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>									 Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   Ёself                                                   	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	     Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       Ёclass RHPERIODO                                              Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
class PeriodoAp
      
	data dDataIni			//Data Inicial passada como referencia
	data dDataFim 			//Data Final   passada como referencia
	data dData				//Data Base
	data lShowHelp			//Mostrar o Help
	data cFilMv				//Filial para GetMv
	data lNewPer			//Se eh para gerar um novo periodo
	data lPerCompleto		//Se o periodo esta preenchido com AAAAMMDD/AAAAMMDD ou AAAAMMDDAAAAMMDD (por referencia)
	data lIncDate			//Se Quando lNewPer Incrementa Data, caso contrario Decrementa
	data lUseParamPer		//Se quando periodo completo considerar dPerIni e dPerFim passados como parametro
    
	method New() constructor    
endclass


/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁNew           Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para instanciar o objeto Periodo						Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj	:= RHPeriodo():New() 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 	
Method New() class PeriodoAp
	::dDataIni		:=	Ctod('')	//Data Inicial passada como referencia
	::dDataFim 		:=	Ctod('')	//Data Final   passada como referencia
	::dData			:=	dDataBase	//Data Base
	::lShowHelp		:=	.T.			//Mostrar o Help
	::cFilMv		:=	cFilAnt		//Filial para GetMv
	::lNewPer		:=	.F.			//Se eh para gerar um novo periodo
	::lPerCompleto	:=	.F.			//Se o periodo esta preenchido com AAAAMMDD/AAAAMMDD ou AAAAMMDDAAAAMMDD (por referencia)
	::lIncDate		:=	.T.			//Se Quando lNewPer Incrementa Data, caso contrario Decrementa
	::lUseParamPer	:=	.F.			//Se quando periodo completo considerar dPerIni e dPerFim passados como parametro
Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁAaDDPer       Ё Autor Ё Mauricio MR       Ё Data Ё25/06/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para adicionar periodos 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:AaDDPer(aItensPer,nPos) 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁATENCAO   ЁVerificar a possibilidade de alimentar recursivamente os    Ё
Ё          Ёatributos do oPeriodo atraves desse metodo.                 Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
Method aADDPer(aItensPer,nPos) class RHPeriodo
Local nX
Local nPer

DEFAULT aItensPer		:= {;
    							{	 ::cFilRCH		,; //01
    								 ::cProcesso	,; //02
    								 ::cPeriodo		,; //03
    								 ::cRoteiro		,; //04
    								 ::cNumPagto	,; //05
    								 ::dDataIni		,; //06
    								 ::dDataFim		,; //07
    								 ::dDtFecha		,; //08
    								 ::cAno			,; //09
    								 ::cMes  		;  //10
    							};
   							}

nPer	:= Len(aItensPer)

For nX:=1 to nPer
    If ( nPos := Ascan(::aPeriodos,{|X|;
    						( X[1] + X[2] + X[3] + X[4] + X[5] ) ==;
    						( aItensPer[nX,1]+ aItensPer[nX,2] + aItensPer[nX,3] + aItensPer[nX,4] + aItensPer[nX,5] )	;
    					   };
    		  );
     	) == 0    
 	  	AADD(::aPeriodos, aItensPer[nX] )
 	  	nPos := Len(::aPeriodos)
 	Endif  	
Next

Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁGetPer        Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para obter o QUALQUER Periodo de Apontamento			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:GetPer(cFiltro)		 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 
Method GetPer(cFiltro,lSemEspaco) class RHPeriodo
Local cKey      

DEFAULT cFiltro		:= "Eval({||.T.})"
DEFAULT	lSemEspaco	:= .T.
                                                   
cKey:= ::cProcesso + ::cRoteiro + ::cPeriodo + ::cNumPagto
cKey:= If(lSemEspaco, ::cFilRCH + Alltrim(cKey), cKey)
    
//04 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" )))        
fPosAlias("RCH", 4, cKey, cFiltro)    

::PerLoad()

Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁPriAberto     Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para obter o Periodo de Apontamento ABERTO			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:PriAberto(cFiltro)		 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
Method PriAberto(cFiltro) class RHPeriodo
         
    DEFAULT cFiltro		:= "Eval({||.T.})"

    //05 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+DTOS(RCH_DTFECH)+RCH_PER+RCH_NUMPAG" )))    
	fPosAlias("RCH", 5, ::cFilRCH + ::cProcesso + ::cRoteiro + "", cFiltro)    
	
    ::PerLoad()
Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁPerAberto     Ё Autor Ё Leandro Drumond   Ё Data Ё27/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para obter o Periodo de Apontamento ABERTO			Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:PerAberto(cFiltro)		 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
Method PerAberto(cFiltro) class RHPeriodo
         
    DEFAULT cFiltro		:= "Eval({||.T.})"

	//02 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+DTOS(RCH_DTFECH)+RCH_ROTEIR" )))
	fPosAlias("RCH", 2, ::cFilRCH + ::cProcesso + ::cPeriodo + Space(8) + ::cRoteiro, cFiltro)    
	
    ::PerLoad()
Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁPerUltFech    Ё Autor Ё Mauricio MR		  Ё Data Ё04/12/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para obter o Ultimo Periodo de Apontamento FECHADO	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:PerUltFech(cFiltro)		 							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/ 

Method PerUltFech(cFiltro) class RHPeriodo

Private nLastRec	:= 0
         
DEFAULT cFiltro		:= "Eval({||fbPerUltFech(cKey)})"

	//04 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" )))  
	fPosAlias("RCH", 4, ::cFilRCH + ::cProcesso + ::cRoteiro, cFiltro,Nil)    	
    
    ::PerLoad()
Return(Nil)         

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁPerSel        Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para obter o Periodo de Apontamento SELECIONADO		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:PerSel(cFiltro)	 	 								Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
Method PerSel(cFiltro) class RHPeriodo
        
     DEFAULT cFiltro		:= "Eval({||.T.})"
    
    //08 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL" )))    
	fPosAlias("RCH", 8, ::cFilRCH + ::cProcesso + ::cRoteiro + "1", cFiltro)
	 
    ::PerLoad()
Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁPerAnt        Ё Autor Ё Igor Franzoi      Ё Data Ё28/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para retornar o Periodo Anterior ao periodo aberto   Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:PerAnt()  		   								    	Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Method PerAnt(cFiltro) class RHPeriodo

	DEFAULT cFiltro := "Eval({|| .T. })"

    //09 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_DTINI" )))    
	fPosAlias("RCH", 9, ::cFilRCH + ::cProcesso + ::cRoteiro + Dtos(::dDataIni), cFiltro)
	
	::PerLoad()
	
Return (Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁPerLoad       Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo p/ Carregar as informacoes do Periodo de Apontamento Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:PerLoad()	   								            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Method PerLoad() class RHPeriodo
    
        
	::cAntFilRCH	:= ::cFilRCH
	::cAntPeriodo	:= ::cPeriodo
	::cAntNumPagto	:= ::cNumPagto	
	
	::dAntDataIni	:= ::dDataIni
	::dAntDataFim	:= ::dDataFim 
	::dAntDtFecha	:= ::dDtFecha 	
	
	::cAntAno		:= ::cAno
	::cAntMes		:= ::cMes
		
	::lAntFechado	:= ::lFechado
	::lAntAberto	:= ::lAberto
	::lAntFound		:= ::lFound
	::nAntRecno		:= ::nRecno  

	::cFilRCH	:= RCH->RCH_FILIAL
	::cPeriodo	:= RCH->RCH_PER
	::cNumPagto	:= RCH->RCH_NUMPAG	
	
	::dDataIni	:= RCH->RCH_DTINI
	::dDataFim	:= RCH->RCH_DTFIM 
	::dDtFecha	:= RCH->RCH_DTFECH
	
	::cAno		:= RCH->RCH_ANO
	::cMes		:= RCH->RCH_MES
	
	::lPerSel	:= If( (RCH->RCH_PERSEL == "1"), .T., .F. )
		
	::lFechado	:= !Empty(::dDtFecha)
	::lAberto	:= Empty(::dDtFecha)
	
	::lFound		:= !RCH->(Eof()) 
	
	::nRecno	:= IF(::lFound, RCH->(Recno()), 0)
	
	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁVerifica se Usa SIGAPON com Cadastro de Periodos			  Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	
	If ( ::lPGenerico	:= ( !( ::lFound ) .and. Empty( ::cPeriodo ) .and. Empty( ::cNumPagto ) ) ) 
		/*/
		зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		ЁAlimenta os atributos do objeto com as informacoes do periodoЁ
		Ёde apontamento												  Ё
		юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/  
		If !Empty(::lPerAponta)
			(::lFound:= GetPonMesDat( @::dDataIni , @::dDataFim , xFilial('SRA') ) )
		Else
			::oPerAponta:dDataIni:= IF( Empty(::oPerAponta:dDataIni),::dDataIni,::oPerAponta:dDataIni )	//Data Inicial passada como referencia
			::oPerAponta:dDataFim:= IF( Empty(::oPerAponta:dDataFim),::dDataFim,::oPerAponta:dDataFim ) 	//Data Final   passada como referencia 
			
			::lFound:= PerAponta(		@::oPerAponta:dDataIni		,;	//Data Inicial passada como referencia
										@::oPerAponta:dDataFim 		,;	//Data Final   passada como referencia
										@::oPerAponta:dData		 	,;	//Data Base
										@::oPerAponta:lShowHelp	  	,;	//Mostrar o Help
										@::oPerAponta:cFilMv		,;	//Filial para GetMv
										@::oPerAponta:lNewPer	 	,;	//Se eh para gerar um novo periodo
										@::oPerAponta:lPerCompleto	,;	//Se o periodo esta preenchido com AAAAMMDD/AAAAMMDD ou AAAAMMDDAAAAMMDD (por referencia)
										@::oPerAponta:lIncDate		,;	//Se Quando lNewPer Incrementa Data, caso contrario Decrementa
										@::oPerAponta:lUseParamPer	;	//Se quando periodo completo considerar dPerIni e dPerFim passados como parametro								 
								 ) 
								 
			::dDataIni	:=::oPerAponta:dDataIni						
			::dDataFim  :=::oPerAponta:dDataFim 						 
		Endif
	
		::cFilRCH		:= xFilial("RCH", SRA->RA_FILIAL)
		::cRoteiro      := "PON"
	    ::cPeriodo		:= ""
	    ::cNumPagto		:= ""

	    ::cAno			:= ""
	    ::cMes			:= ""

		::lFechado		:= .F.
		::lAberto		:= .F.		

		::nRecno		:= 0				
			
	Else
		/*
		::cFilRCH	:= RCH->RCH_FILIAL
		::cPeriodo	:= RCH->RCH_PER
		::cNumPagto	:= RCH->RCH_NUMPAG	
		
		::dDataIni	:= RCH->RCH_DTINI
		::dDataFim	:= RCH->RCH_DTFIM 
		::dDtFecha	:= RCH->RCH_DTFECH
		
		::cAno		:= RCH->RCH_ANO
		::cMes		:= RCH->RCH_MES
			                                            
			
			
			
		::lFechado	:= !Empty(::dDtFecha)
		::lAberto	:= Empty(::dDtFecha)
	
		::nRecno	:= IF(::lFound, RCH->(Recno()), 0)
        */
	Endif      
	
	::aADDPer()	
Return(Nil)	

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁMetodo    ЁRollBack      Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁMetodo para retornar ao ultimo Periodo de Apontamento VALIDOЁ
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁ															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁoObj:RollBack()  		   								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Method Rollback() class RHPeriodo

	::cFilRCH	:= ::cAntFilRCH
	::cPeriodo	:= ::cAntPeriodo
	::cNumPagto	:= ::cAntNumPagto	
	
	::dDataIni	:= ::dAntDataIni
	::dDataFim	:= ::dAntDataFim 
	::dDtFecha	:= ::dAntDtFecha 	
	
	::cAno		:= ::cAntAno
	::cMes		:= ::cAntMes
		
	::lFechado	:= ::lAntFechado
	::lAberto	:= ::lAntAberto
	::lFound	:= ::lAntFound 
	::nRecno	:= ::nAntRecno	
	
	IF ::lFound
		RCH->(MsGoto(::nRecno))
	Else	
		RCH->(DbGoBottom())
    Endif                
    
Return(Nil)	

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFuncao    ЁfPosAlias     Ё Autor Ё Mauricio MR       Ё Data Ё26/11/2007Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁFuncao para Posicionar em determinado Registro de um Alias  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁVer parametros  											Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁVer parametros  		   								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/                     
Static Function fPosAlias(;
 							cAlias		,; //Alias para a ser pesquisado
 							nIndex		,; //Numero do indice para pesquisa
 							cKey		,; //Chave para busca do registro
 							cFiltro		,; //Condicao de filtro do registro (OPCIONAL)
 							lRePosiciona,; //.T. reposiciona para o registro anterior a pesquisa (OPCIONAL)
 							nPosicao	 ; //Retrocede n registros a partir da posicao do alias
 						)
    
	Local aArea			:= GetArea()
	Local aRCHArea		:= RCH->(GetArea())
	Local bWhile		:= {}

    DEFAULT cFiltro		:= "Eval({||.T.})"
	DEFAULT lRePosiciona:= .F.
	DEFAULT nPosicao	:= 1
	
	
	
	If ( nPosicao >= 0 )
		bWhile := {|| !Eof() }
	Else
		bWhile := {|| !Bof() }	
	EndIf
	(cAlias)->(dbSetOrder(nIndex))
	(cAlias)->(MsSeek(cKey))
	
	WHILE 	(cAlias)->(Eval(bWhile))
		IF (cAlias)->(&(cFiltro) == .T.)
			EXIT
		ENDIF
		(cAlias)->(dbSkip(nPosicao))
	ENDDO           
    
    IF lRePosiciona
		RestArea( aRCHArea )
		RestArea( aArea )
	Else
		IF Alltrim(Upper(aArea[1])) <> Alltrim(Upper(aRCHArea[1]))
			RestArea( aArea )
		Endif	
	Endif	
	
Return(Nil)

/*/
зддддддддддбддддддддддддддбдддддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFuncao    ЁfbPerUltFech  Ё Autor Ё Mauricio MR       Ё Data Ё12/06/2008Ё
цддддддддддеддддддддддддддадддддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁFuncao para filtrar ultimo registro fechado					Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁPar┐metrosЁVer parametros  											Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁVer parametros  		   								    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerico                                                    Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/    
Static Function fbPerUltFech(cKey)                           
Local lRet := .F.

//Armazena o ultimo registro lido para o roteiro pesquisado
If (RCH_FILIAL+RCH_PROCES+RCH_ROTEIR) == ( cKey )
	If !EMPTY(RCH_DTFECH)
		nLastRec := RCH->(Recno())
		lRet 	 := .T.
	EndIf
   //Continua a busca se a data de fechamento permanece vazia (periodo aberto) ou
   //finaliza a pesquisa se o periodo for fechado
Else                                             
   // Se houver quebra de chave 
   RCH->(MsGoto(nLastRec))
   lRet	:= .T.
Endif                     

Return (lRet)

//01 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )))
//02 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+DTOS(RCH_DTFECH)+RCH_ROTEIR" )))
//03 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+DTOS(RCH_DTFECH)+RCH_ROTEIR" )))
//04 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" )))
//05 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+DTOS(RCH_DTFECH)+RCH_PER+RCH_NUMPAG" )))
//06 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_ANO+RCH_MES" )))
//07 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_ANO+RCH_MES" )))
//08 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL" )))




#Include 'Protheus.ch'

/*/{Protheus.doc} ExtCtrCred
	(Realiza a geracao do registro T067 do TAF)

	@type Function
	@author Rodrigo Aguilar
	@since 26/12/2016

	@param a_Wizard, array, InFormaçoes da Wizard do extrator fiscal 
	@param a_LisFil, array, Array de seleção de filiais no Formato padrão da rotina BlocoG

	@Return lGerou, logico, se gerou ou não.
	/*/
Function ExtCtrCred(aWizard,aLisFil)

local cAlias   := ""
local cFilDe   := "" 
local cFilAte  := "" 

local lEnd     := .F.
local lGerou   := .F.

local dDataDe  := aWizard[1][3]
local dDataAte := aWizard[1][4]

local nCtdFil  := 0
local nI       := 0   
local ny       := 0   
local nIniReg  := 0      

local aRegT067   := {} 
local aRegT067AA := {} 

local bWhileSM0  := NIL

Local oProcess   := Nil
Local cTxtSys    := cDirSystem + IIf(isSrvUnix(),"/","\")

cAlias   := '' 

nCtdFil  := 1 ; nI := 1 ; nIniReg := 0 ; nY := 0 

//-----------------------------------------------------------------------------------------------
//se o usuário selecionou as filiais de processamento eu preciso setar de "" a "zz" as filiais de
//processamento, visto que o controle de qual filial será processada ficara a cargo do aLisFil 
//-----------------------------------------------------------------------------------------------
if !empty( aLisFil )
	cFilDe	:=	PadR("",FWGETTAMFILIAL)
	cFilAte	:=	Repl("Z",FWGETTAMFILIAL)

//-------------------------------------------------------------------------------
//Caso contrário considero apenas a filial corrente para processamento do Bloco G                
//-------------------------------------------------------------------------------
else
	cFilDe  := cFilAnt  
	cFilAte := cFilAnt  
endif            

//----------------------------------------------------------------------------------------------------
//Executo somente para a filial que esta sendo processada dentro do laço, cada filial terá seus dados
//----------------------------------------------------------------------------------------------------
bWhileSM0	:= {|| !SM0->(Eof()) .And. cEmpAnt == SM0->M0_CODIGO }

R12001210( bWhileSM0, cFilDe, dDataDe, dDataAte, cAlias, aWizard,;
		   oProcess, 0, nCtdFil, aLisFil, 0, ;
		   @lEnd, cFilAte, .T., aRegT067, aRegT067AA )

//---------------------------------------------------------------
//Somente sigo a geração se houver  movimentação do registro T067	    	
//---------------------------------------------------------------
if len( aRegT067 ) > 0
	lGerou := .T.

   	nHdlTxt := IIf( cTpSaida == "1" , MsFCreate( cTxtSys + "T067.TXT" ) , 0 )     
   	Aadd(aArqGer, ( cTxtSys + "T067.TXT" ) )
        		
	for nI := 1 to len( aRegT067 )
		
		//--------------------------
		//Geração do registro T067
		//--------------------------
		RegT067( nHdlTxt, aRegT067[nI], dDataDe ) 

		//------------------------------------
		//Laço para Geração do registro T067AA
		//------------------------------------
		nIniReg := aScan( aRegT067AA, {|x| x[1] == nI })		
		if nIniReg > 0

			for nY := nIniReg to len( aRegT067AA )			  
			
				if aRegT067AA[ny][1] == nI					
					RegT067AA( nHdlTxt, aRegT067AA[nY] )												
				else
					exit
				endif					
			next
		endif	
		
		//-----------------------------------
		//Grava o registro na TABELA TAFST1 
		//-----------------------------------
		If cTpSaida == "2"
			FConcST1()
		EndIf	
							
	next 
	
	If cTpSaida == "1" 
		FClose( nHdlTxt )
	EndIf	

endif   
	
Return lGerou

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT067
Realiza a geracao do registro T067 do TAF

@Param nHdlTxt   -> Handle de geracao do Arquivo
		aregT067 -> Array com informacoes do registro T067
		dDataDe  -> Data de inicio do processamento para geração da data do movimento

@Return ( Nil )

@author Rodrigo Aguilar
@since  26/12/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function RegT067( nHdlTxt, aRegT067, dDataDe )

cDataDe := left(dtos(dDataDe),6) + "01" //O dia do movimento sempre sera o primeiro dia do Mes
			
aRegs := {}
Aadd( aRegs, {  'T067',;
				  cDataDe,;
				  aRegT067[02],;
				  Val2Str( aRegT067[03], 16, 2 ),;
				  Val2Str( aRegT067[04], 16, 2 ),;
				  Val2Str( aRegT067[05], 16, 2 ),;
				  Val2Str( aRegT067[06], 16, 2 ),;
				  Val2Str( aRegT067[07], 16, 2 ) } )
								
FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )   

//-------------------------------------------------------------------
/*/{Protheus.doc} RegT067AA
Realiza a geracao do registro T067AA do TAF

@Param nHdlTxt    -> Handle de geracao do Arquivo
		aRegT067AA -> Array com informacoes do registro T067AA

@Return ( Nil )

@author Rodrigo Aguilar
@since  26/12/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function RegT067AA( nHdlTxt, aRegT067AA )
			
aRegs := {}
Aadd( aRegs, {  'T067AA',;
				aRegT067AA[03],;
				aRegT067AA[04],;
				Val2Str( aRegT067AA[05], 16, 2 ) } )
								
FConcTxt( aRegs, nHdlTxt )
	
Return ( Nil )
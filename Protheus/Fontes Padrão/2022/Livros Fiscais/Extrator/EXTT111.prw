#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ExtT111
Função responsável pela geração do registro T111 do Layout TAF 
Informações Provenientes da DIPJ

@Param 	dDataAte   - Data final do período de processamento

@author Rodrigo Aguilar
@since 05/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
function ExtT111( dDataAte )

local cRegistro  := ''
local cSocio     := ''
local cCPFRepLeg := ''
local cQuaRepLeg := ''
local cDtaIncSoc := ' / / '
local cDtaFimSoc := ' / / '
local cCAPVOT	   := '0'

local cSepar := '|'

local aSocio := {}

SX6->( DbSetOrder( 1 ) )
if SX6->( MsSeek( xFilial( 'SX6' ) + 'MV_REGSOC' ) )
	do while SX6->( !Eof() ) .And. xFilial( 'SX6' ) == SX6->X6_FIL .And. 'MV_REGSOC' $ SX6->X6_VAR
		if !Empty( SX6->X6_CONTEUD )
			
			cSocio := AllTrim( SX6->X6_CONTEUD )
			aSocio := iif( len( &( cSocio ) ) < 6, {}, &( cSocio ) )          
			
			if len( aSocio ) >= 8
				cCPFRepLeg	:= aSocio[7]
				cQuaRepLeg	:= aSocio[8]
				
				if len( aSocio ) >= 10
					cDtaIncSoc	:= aSocio[9]
					cDtaFimSoc	:= aSocio[10]					
				endif 
				
				if len( aSocio ) >= 11
					cCAPVOT := aSocio[11]					
				endif 
				
			endif			
			
			if ( len( aSocio ) >= 6 )
			
				cRegistro   := cSepar 
				cRegistro   += 'T111' + cSepar												//REGISTRO 	
				cRegistro   += dToS( dDataAte ) + cSepar									//PERIODO
				cRegistro   += Alltrim( dToS( cTod( cDtaIncSoc ) ) ) + cSepar			//DT_INCL_SOC
				cRegistro   += Alltrim( dToS( cTod( cDtaFimSoc ) ) ) + cSepar			//DT_FIM_SOC
				cRegistro   += Alltrim( aSocio[1]  ) + cSepar 							//PAIS
				cRegistro   += Alltrim( iif(len(aSocio[2])>=2,Substr(aSocio[2],2,1),aSocio[2])  ) + cSepar 							//IND_QUALIF_SOCIO
				cRegistro   += Alltrim( aSocio[3]  ) + cSepar								//CPF_CNPJ
				cRegistro   += Alltrim( aSocio[4]  ) + cSepar 					   		//NOME_EMP
				cRegistro   += Alltrim( aSocio[5]  ) + cSepar 							//QUALIF											
				cRegistro   += "" + cSepar 												//DESC. QUALIF - Campo 10 OBSOLETO no Layout TAF deve passar a posição vazia
				cRegistro   += Alltrim( aSocio[6]  ) + cSepar  							//PERC_CAP_TOT
				cRegistro   += cCAPVOT 					  + cSepar	 							//PERC_CAP_VOT
				cRegistro   += Alltrim( cCPFRepLeg ) + cSepar			 					//CPF_REP_LEG
				cRegistro   += Alltrim( cQuaRepLeg ) + cSepar		 	 					//QUALIF_REP_LEG
				
			endif
		endif		

		//Função para realizar a gravação na tabela TAFST1				
		if !Empty(cRegistro)					
			ECFParseDIPJ( cRegistro ) 			
		endif
		
		SX6->( DbSkip() )
	enddo
endif

return ( nil )



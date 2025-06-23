//
//  SupabaseService.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient
    private init() {
        let url = URL(string: "https://nmzzxpppivylrnzsbmzu.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5tenp4cHBwaXZ5bHJuenNibXp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5NDUzNTYsImV4cCI6MjA2MzUyMTM1Nn0.V7FV8pUKMLFanGJSHiohju0bQixJqkOXw_SF067VKnk"
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
} 

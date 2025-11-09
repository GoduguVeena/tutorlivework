using System;

namespace TutorLiveMentor.Helpers
{
    /// <summary>
    /// Helper class to normalize department names and prevent CSE(DS) vs CSEDS mismatch issues
    /// </summary>
    public static class DepartmentNormalizer
    {
        /// <summary>
        /// Normalizes department names to standard format
        /// CSEDS, CSDS, CSE-DS, CSE (DS), CSE_DS, CSE DATA SCIENCE -> CSE(DS)
        /// CSE(AIML), CSEAIML, CSE-AIML -> CSE(AIML)
        /// CSE(CS), CSECS, CSE-CS -> CSE(CS)
        /// CSE(BS), CSEBS, CSE-BS -> CSE(BS)
        /// </summary>
        /// <param name="department">Raw department name from user input</param>
        /// <returns>Normalized department name</returns>
        public static string Normalize(string department)
        {
            if (string.IsNullOrWhiteSpace(department))
                return department;

            // Trim whitespace and convert to uppercase for comparison
            var normalized = department.Trim();
            var upper = normalized.ToUpper();

            // ===== CSE DATA SCIENCE VARIANTS =====
            // These should all map to "CSE(DS)" - the user-facing format
            if (upper == "CSEDS" || upper == "CSDS" || upper == "CSE-DS" || 
                upper == "CSE (DS)" || upper == "CSEDATASCIENCE" ||
                upper == "CSE DATA SCIENCE" || upper == "CSE_DS" || upper == "CSE(DS)")
            {
                return "CSE(DS)";  // Changed from "CSEDS" to "CSE(DS)"
            }

            // ===== CSE AI/ML VARIANTS =====
            if (upper == "CSE(AIML)" || upper == "CSEAIML" || upper == "CSE-AIML" ||
                upper == "CSE (AIML)" || upper == "CSE_AIML")
            {
                return "CSE(AIML)";
            }

            // ===== CSE CYBER SECURITY VARIANTS =====
            if (upper == "CSE(CS)" || upper == "CSECS" || upper == "CSE-CS" ||
                upper == "CSE (CS)" || upper == "CSE_CS")
            {
                return "CSE(CS)";
            }

            // ===== CSE BUSINESS SYSTEMS VARIANTS =====
            if (upper == "CSE(BS)" || upper == "CSEBS" || upper == "CSE-BS" ||
                upper == "CSE (BS)" || upper == "CSE_BS")
            {
                return "CSE(BS)";
            }

            // Return original if no match found
            return normalized;
        }

        /// <summary>
        /// Checks if a department name needs normalization
        /// </summary>
        /// <param name="department">Department name to check</param>
        /// <returns>True if the department name has a variant that needs normalization</returns>
        public static bool NeedsNormalization(string department)
        {
            if (string.IsNullOrWhiteSpace(department))
                return false;

            var normalized = Normalize(department);
            return !string.Equals(department.Trim(), normalized, StringComparison.Ordinal);
        }

        /// <summary>
        /// Gets the standard display name for a department
        /// </summary>
        /// <param name="department">Normalized department code</param>
        /// <returns>Full department name for display</returns>
        public static string GetDisplayName(string department)
        {
            if (string.IsNullOrWhiteSpace(department))
                return department;

            return department.ToUpper() switch
            {
                "CSE(DS)" => "CSE (Data Science)",  // Changed from "CSEDS"
                "CSEDS" => "CSE (Data Science)",    // Support legacy format
                "CSE(AIML)" => "CSE (Artificial Intelligence and Machine Learning)",
                "CSE(CS)" => "CSE (Cyber Security)",
                "CSE(BS)" => "CSE (Business Systems)",
                "CSE" => "Computer Science and Engineering",
                "ECE" => "Electronics and Communication Engineering",
                "EEE" => "Electrical and Electronics Engineering",
                "MECH" => "Mechanical Engineering",
                "CIVIL" => "Civil Engineering",
                _ => department
            };
        }
    }
}
